# myDogGallery

### 프로젝트 소개
반려견을 위한 앱을 개발했습니다. 이 앱은 사용자가 손쉽게 반려동물의 정보를 등록하고 확인할 수 있는 서비스를 제공합니다. 
1. 사용자는 자신의 반려동물의 정보를 앱에 등록하고 필요할 때마다 열람하거나 추가할 수 있습니다.
2. 산책에 있었던 일 기록할 수 있고 산책 경로, 시간 등을 저장할 수 있습니다.
3. 산책하기전에 오늘의 날씨를 알 수 있습니다.

### 개발 기간
- 2023년 02월 ~ 2023 06월
### 기술 스택
  - Language : Swift
  - Framework : UIKit, CoreData, PhotoKit, Mapkit, Core Loaction
  - Library : Moya, KeychainSwift, AuthenticationServices, SDWebImage, SwiftLint
    
### 기능 

<br/>

| <img width="300" height="360" src="https://github.com/LeeHongYul/TIL/assets/117960228/03dfd7d3-751a-410a-8a5d-5c565e6a7864"> | <img width="300" height="360" src="https://github.com/LeeHongYul/TIL/assets/117960228/b72d6b1a-6b53-43be-89ff-148c1011c68d"> | <img width="300" height="360" src="https://github.com/LeeHongYul/TIL/assets/117960228/cfe066f6-0c7d-456e-a26e-0f5c3ce9d447"> | <img width="300" height="360" src="https://github.com/LeeHongYul/WorkoutCycle/assets/117960228/76f6068b-ea78-4581-946f-6710cf1fbb7c"> | <img width="300" height="360" src="https://github.com/LeeHongYul/TIL/assets/117960228/1664bdb8-5440-426f-9913-162b9903660c"> |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|  `애플로그인`   |  `프로필 등록`  | `산책 기록`  | `오늘의 꿀팁` | `앨범 연동` |

<br/>

### UI
<img width="250" height="360" src="https://github.com/LeeHongYul/WorkoutCycle/assets/117960228/491c9b99-314b-419d-b241-d0b367cb42f7"> <img width="250" height="360" src="https://github.com/LeeHongYul/WorkoutCycle/assets/117960228/84354a58-3a88-4ab8-9b31-2e35a3d78e29"> <img width="250" height="360" src="https://github.com/LeeHongYul/WorkoutCycle/assets/117960228/1a870444-80fc-4132-9312-f84f3fdddc35"> <img width="250" height="360" src="https://github.com/LeeHongYul/WorkoutCycle/assets/117960228/139bf6c7-3ff0-4aef-a980-60620f9f2d40"> <img width="250" height="360" src="https://github.com/LeeHongYul/WorkoutCycle/assets/117960228/2ccf384f-679d-4917-8aad-a3e1f5008e44"> <img width="250" height="360" src="https://github.com/LeeHongYul/WorkoutCycle/assets/117960228/320d5fa4-c56b-4a4c-8c79-3e4203b4f8d0"> <img width="250" height="360" src="https://github.com/LeeHongYul/WorkoutCycle/assets/117960228/c6ae3d0f-d5b9-46df-9f35-1d2ddd2107ba">

### 개발 상세
<details>
<summary>OpenWeather API, Moya 활용</summary>
<div markdown="1">
간단한 코드로 네트워크 요청을 생성할 수 있도록 Moya를 적용했습니다.<br>
JSON 데이터를 디코딩하기 위한 JSONDecoder 객체를 생성하고. API 응답 데이터(data)를 Forcast 객체로 디코딩했습니다.<br>
  
```swift
let decoder = JSONDecoder()

let list = try decoder.decode(Forcast.self, from: data)JSONDecoder
```
</div>
</details>
<details>
<summary>앨범 연동</summary>
<div markdown="1">
Photos framework를 사용하여 사진 정보를 가져오도록 하였습니다.<br>
사진을 가져올 때 사용할 옵션을 위한 PHFetchOptions 객체 options를 생성하며 
options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]:
옵션인 sortDescriptors를 설정하여 내림차순으로 정렬되로록 하였습니다.<br>
  
```swift
var assets = [PHAsset]()
let options = PHFetchOptions()
options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
```
</div>
</details>
<details>
<summary>NSPredicate 활용하여 산책 기록 제목 검색</summary>
<div markdown="1">
주어진 키워드를 사용하여 산책 기록의 제목(title)에서 검색하는 기능을 구현했습니다.<br>
검색을 위한 NSPredicate 객체 predicate를 생성했으며 "title CONTAINS[c] keyword"라는 조건을 넣었습니다.<br>

```swift
func searchByName(_ keyword: String?) {
guard let keyword = keyword else { return }

let predicate = NSPredicate(format: "title CONTAINS[c] %@", keyword)

fetchSearchedMemo(predicate: predicate)
}
```
</div>
</details>
<details>
<summary>애플 로그인에서 Keychain 사용</summary>
<div markdown="1">
애플 로그인 Keychain을 활용하여 이미 로그인한 사용자를 기억하는 기능을 구현하였고, 앱에 다음 접속 시 사용자의 이름을 label에 표시하도록 하였습니다.<br>
Apple 로그인을 수행한 후에 제공되며, 사용자의 ID, 이름, 이메일 주소 등과 같은 정보를 담고 있는 ASAuthorizationAppleIDCredential를 활용했습니다.<br>
</div>
</details>



### 고민 과정
<details>
<summary>TableCell Pin 기능 문제</summary>
<div markdown="1">
사용자 정보를 저장하기 위해 CoreData를 사용했고, 저장된 프로필을 TableView로 표시할 때 Pin(상단 고정) 기능을 구현하려고 했습니다.<br>
처음에는 상단 고정 기능은 정상적으로 작동하지만, 앱이 종료된 후 다시 확인해보면 상단 고정 설정이 저장되지 않는 문제가 발생했습니다.<br>
이 문제를 해결하기 위해, 데이터 모델에 Pin 어트리뷰트를 추가하고, 사용자가 프로필을 상단 고정할 경우 해당 어트리뷰트를 true로 설정하여 상태를 저장했습니다.<br>
마지막으로 TableView를 생성할 때, Pin이 true인 프로필만 fetch하는 fetchRequest를 사용하여 데이터를 가져오도록 구현했습니다.<br>
이렇게 함으로써 상단 고정 설정이 앱이 종료되더라도 영구적으로 유지되는 문제를 해결했습니다.<br>
  
```swift
func fetchProfileByPin() {
  let request = ProfileEntity.fetchRequest()
  let sortByPin = NSSortDescriptor(key: "pin", ascending: false)
  
  request.sortDescriptors = [sortByPin]
  do {
      profileList = try mainContext.fetch(request)
  } catch {
      print(error)
  }
}
```
</div>
</details>
<details>
<summary>UICollectionViewDiffableDataSource으로 앨범 연동</summary>
<div markdown="1">
기존의 UICollectionViewDataSource는 데이터를 관리하고 셀을 구성하는 데 필요한 메서드들을 수동으로 구현해야 했습니다.<br>
하지만 UICollectionViewDiffableDataSource를 사용하면 데이터를 섹션과 아이템으로 구성된 스냅샷(Snapshot)으로 관리하기 때문에 기존 데이터를 업데이트하면 자동으로 새로운 레이아웃이 적용되는 기능을 제공하여서 UICollectionViewDiffableDataSource를 사용했습니다.<br>
결론적으로 스크롤도 부드러워지고 뷰를 업데이트하는 과정이 효율적으로 처리되었습니다.<br>
</div>
</details>
<details>
<summary>산책했던 경로를 저장하기 위한 방법 변경</summary>
<div markdown="1">
MapKit을 사용하여 MapView 위에 선을 그리기 위해 MKMapSnapshotter을 활용하여 Snapshot을 찍어 이미지로 데이터를 저장하는 방식 대신, 좌표 두 개만 저장하고 필요할 때마다 선을 그리는 방식으로 구현했습니다.<br>
이렇게 함으로써 이미지의 크기가 크기 때문에 발생할 수 있는 메모리 용량 문제를 해결할 수 있었습니다.<br>
즉, 매번 이미지를 저장하지 않고 필요할 때마다 선을 동적으로 그리기 때문에 더 효율적인 메모리 관리가 가능해졌습니다.<br>
</div>
</details>
<details>
<summary>키보드가 UI를 가리는 문제</summary>
<div markdown="1">
기능 구현 후 실제 기기에서 테스트하면서 발생한 문제 중 하나는 키보드가 화면을 가리면서 화면의 반만 사용 가능했던 상황이었습니다.<br>
기존의 뷰를 완전히 엎고 ScrollView를 적용하여 다시 시작했습니다.<br>
ScrollView를 사용하면 화면을 스크롤하여 키보드가 가리는 부분을 볼 수 있게 되므로, 사용자가 편리하게 모든 내용을 확인할 수 있습니다.<br>
처음에는 이러한 문제를 미리 고려하지 못해 아쉬움을 느낄 수 있습니다.<br>
하지만 이러한 경험을 통해 앞으로는 사용자 경험을 개선하는 데 더 주의를 기울일 수 있고, 더 나은 앱을 제공할 수 있게 되었습니다.<br>
</div>
</details>
<details>
<summary>중복되는 코드 해결</summary>
<div markdown="1">
중복되는 코드 navigationBar.tintColor = .orange를 줄이기 위해 고민한 결과, 새로운 BaseViewController를 생성하여 필요한 ViewController에서 상속받도록 구현하였습니다.<br>
또한 extension을 활용하여 타입에 대해 확장 메소드를 만들면서 중복 코드를 줄이고 유지 보수가 편리해지도록 구현하였습니다.<br>
  
```swift
extension Date {
  func dateToString() -> String {
    let dateString = DateFormatter()
    dateString.dateFormat = "MMM d, yyyy"
    dateString.locale = Locale(identifier: "en_US_POSIX")

    return dateString.string(from: self)
  }
}
```
</div>
</details>

### 성장 과정
- Swift 와 다양한 iOS 프레임워크를 활용하여 첫 번째 개인 프로젝트로 원하는 앱을 개발하는 경험을 쌓았습니다.

### 상세 내용
[myDogGallery 포트폴리오](https://bright-melody-10d.notion.site/myDogGallery-5b33a32b5cab43de914cd5446b21440e?pvs=4)
