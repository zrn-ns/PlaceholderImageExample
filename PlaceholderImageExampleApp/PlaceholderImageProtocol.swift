import UIKit

/// プレースホルダー画像を返すためのカスタムURLProtocol
class PlaceholderImageProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        // "placeholder" ドメイン以外を無視
        guard let url = request.url, url.host == "placeholder" else { return false }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        if url.path != "/image.png" {
            // パスが "image.png" でない場合は404を返す
            let response = HTTPURLResponse(
                url: url,
                statusCode: 404,
                httpVersion: nil,
                headerFields: ["Content-Type": "text/plain"]
            )
            client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: "404 Not Found".data(using: .utf8) ?? Data())
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        // クエリパラメータを取得
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        let width = queryItems?.first(where: { $0.name == "width" })?.value.flatMap { Int($0) } ?? 250
        let height = queryItems?.first(where: { $0.name == "height" })?.value.flatMap { Int($0) } ?? 250
        let text = queryItems?.first(where: { $0.name == "text" })?.value ?? "dummy"
        let fgcolor = queryItems?.first(where: { $0.name == "fgcolor" })?.value ?? "202f55"
        let bgcolor = queryItems?.first(where: { $0.name == "bgcolor" })?.value ?? "dddddd"

        // 画像を生成
        let image = generatePlaceholderImage(
            width: width,
            height: height,
            text: text,
            fgColor: UIColor(hex: fgcolor),
            bgColor: UIColor(hex: bgcolor)
        )

        // 画像データをレスポンスとして返す
        if let imageData = image.pngData() {
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "image/png"]
            )
            client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: imageData)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // リクエストのキャンセル処理
    }

    // プレースホルダ画像生成メソッド
    private func generatePlaceholderImage(width: Int, height: Int, text: String, fgColor: UIColor, bgColor: UIColor) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)

            // 背景色を描画
            bgColor.setFill()
            context.fill(rect)

            // テキスト描画の準備
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            // フォントサイズを計算（幅の80%以内、かつ高さの20%以内）
            let maxFontSize = min(CGFloat(width) * 0.8 / CGFloat(max(text.count, 1)), CGFloat(height) * 0.2)
            let font = UIFont.systemFont(ofSize: maxFontSize)

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: fgColor,
                .paragraphStyle: paragraphStyle
            ]

            // テキストの描画範囲を計算
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - font.lineHeight) / 2, // フォントのライン高さを基準に中央揃え
                width: textSize.width,
                height: font.lineHeight
            )

            // テキストを描画
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

// UIColorの16進数表現から初期化
private extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)

        let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        let b = CGFloat(hexNumber & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
