//
//  AssetStore.swift
//  glTFViewer
//
//  Created by Daegeon Choi on 7/25/24.
//

import Foundation

// SampleAssets.plist에 저장된 정보 Model
struct LocalAssetDescription {
    var displayName: String
    var filename: String
    var previewImageName: String

    var assetURL: URL? {
        return Bundle.main.url(forResource: filename, withExtension: nil)
    }

    var previewImage: UIImage? {
        guard let thumbnail = UIImage(named: previewImageName) else {
            // TODO: Add fallback thumbnail image?
            print("Could not find preview image named \(previewImageName) in app bundle")
            return nil
        }
        return thumbnail
    }
}

// SampleAssets.plist에서 정보 추출
class SampleAssetStore {
    static let `default` = SampleAssetStore()

    let assets: [LocalAssetDescription]

    init() {
        do {
            let sampleAssetURL = Bundle.main.url(forResource: "SampleAssets", withExtension: "plist")!
            let plistData = try Data(contentsOf: sampleAssetURL)
            var format = PropertyListSerialization.PropertyListFormat.xml
            let root = try PropertyListSerialization.propertyList(from: plistData, format:&format)
            if let assetArray = root as? [[String : Any]] {
                assets = assetArray.map({ assetDescription in
                    return LocalAssetDescription(displayName: assetDescription["displayName"] as? String ?? "",
                                                 filename: assetDescription["filename"] as? String ?? "",
                                                 previewImageName: assetDescription["previewImageName"] as? String ?? "")
                })
            } else {
                print("Did not find sample assset plist in correct format in app bundle")
                assets = []
            }
        } catch {
            print("Error when deserializing sample asset plist: \(error)")
            assets = []
        }
    }
}
