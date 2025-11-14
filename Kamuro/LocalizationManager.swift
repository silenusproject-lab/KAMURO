import Foundation
import Combine

// 多言語対応を管理するクラス - アプリ全体のテキスト翻訳を一元管理
class LocalizationManager: ObservableObject {
    // 対応言語の列挙型 - 16言語対応
    enum Language: String, CaseIterable {
        case japanese = "ja"
        case english = "en"
        case chineseSimplified = "zh-Hans"
        case chineseTaiwan = "zh-Hant"
        case korean = "ko"
        case spanish = "es"
        case arabic = "ar"
        case indonesian = "id"
        case malay = "ms"
        case portuguese = "pt"
        case french = "fr"
        case german = "de"
        case italian = "it"
        case vietnamese = "vi"
        case thai = "th"
        case burmese = "my"

        // 各言語のネイティブ表示名
        var displayName: String {
            switch self {
            case .japanese: return "日本語"
            case .english: return "English"
            case .chineseSimplified: return "简体中文"
            case .chineseTaiwan: return "繁體中文"
            case .korean: return "한국어"
            case .spanish: return "Español"
            case .arabic: return "العربية"
            case .indonesian: return "Bahasa Indonesia"
            case .malay: return "Bahasa Melayu"
            case .portuguese: return "Português"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .italian: return "Italiano"
            case .vietnamese: return "Tiếng Việt"
            case .thai: return "ไทย"
            case .burmese: return "မြန်မာ"
            }
        }
    }

    // 現在選択されている言語 - UserDefaultsに保存される
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
        }
    }

    // 翻訳辞書 - 各言語のキーと翻訳文字列のマッピング
    private let translations: [Language: [String: String]] = [
        .japanese: [
            // 共通
            "app_name": "KAMURO",
            "input": "入力",
            "ok": "OK",
            "cancel": "キャンセル",
            "close": "閉じる",
            "error_title": "エラー",
            "settings": "設定",

            // 操作画面
            "launch_point": "打上地点",
            "select_on_map": "地図で選択",
            "use_current_location": "現在地を使用",
            "not_selected": "未選択",
            "latitude_format": "緯度: %.6f",
            "longitude_format": "経度: %.6f",

            // 時間差入力
            "time_difference": "時間差",
            "time_lag_seconds": "タイムラグ（秒）",
            "temperature_celsius": "気温（℃）",
            "temperature_info": "正確な気温を入力することで、より精確な距離計算が可能です",

            // 計算結果
            "calculate": "計算",
            "calculation_result": "計算結果",
            "distance_format": "距離: 約%.0fm",
            "distance_meters": "約%.0fm",
            "view_on_map": "地図で表示",
            "map_with_circle": "距離の円表示",
            "circle_description": "打上地点から計算距離の円を表示",

            // 地図検索
            "search_location": "場所を検索",
            "confirm_location": "この位置で確定",

            // 設定画面
            "language": "言語",
            "information": "情報",
            "version_info": "バージョン情報",
            "about_app": "このアプリについて",
            "specification": "仕様",
            "notice_title": "ご利用上の注意事項",
            "share": "シェア",
            "rate_app": "アプリを評価",

            // アプリについて
            "app_description": "花火の音から撮影位置を逆算するアプリです。花火の開花を見た時刻と音が聞こえた時刻の差から、撮影地点と打上地点の距離を計算します。",
            "sound_speed_info": "音速について",
            "sound_speed_desc": "音速は気温によって変化します。正確な計算のため、撮影時の気温を入力してください。\n音速 = 331.5 + 0.6 × 気温(℃)",
            "location_info": "位置情報について",
            "location_desc": "位置情報はApple Mapsから取得されます。",
            "gps_accuracy": "GPS精度には数メートルの誤差が含まれる場合があります",
            "network_requirement": "地図データの取得にはインターネット接続が必要です",

            // シェアテキスト
            "share_text": "KAMURO - 花火撮影位置計算アプリ\n#KAMURO #花火 #花火撮影",

            // バージョン
            "version": "バージョン 1.0",
        ],
        .english: [
            // Common
            "app_name": "KAMURO",
            "input": "Input",
            "ok": "OK",
            "cancel": "Cancel",
            "close": "Close",
            "error_title": "Error",
            "settings": "Settings",

            // Main Screen
            "launch_point": "Launch Point",
            "select_on_map": "Select on Map",
            "use_current_location": "Use Current Location",
            "not_selected": "Not Selected",
            "latitude_format": "Lat: %.6f",
            "longitude_format": "Lon: %.6f",

            // Time Difference Input
            "time_difference": "Time Difference",
            "time_lag_seconds": "Time Lag (seconds)",
            "temperature_celsius": "Temperature (℃)",
            "temperature_info": "Enter accurate temperature for more precise distance calculation",

            // Calculation Result
            "calculate": "Calculate",
            "calculation_result": "Calculation Result",
            "distance_format": "Distance: Approx. %.0fm",
            "distance_meters": "Approx. %.0fm",
            "view_on_map": "View on Map",
            "map_with_circle": "Distance Circle",
            "circle_description": "Circle with calculated distance from launch point",

            // Map Search
            "search_location": "Search Location",
            "confirm_location": "Confirm Location",

            // Settings Screen
            "language": "Language",
            "information": "Information",
            "version_info": "Version Info",
            "about_app": "About App",
            "specification": "Specification",
            "notice_title": "Usage Notes",
            "share": "Share",
            "rate_app": "Rate App",

            // About App
            "app_description": "This app calculates the shooting location from firework sounds. It calculates the distance between shooting point and launch point from the time difference between seeing firework bloom and hearing the sound.",
            "sound_speed_info": "About Sound Speed",
            "sound_speed_desc": "Sound speed varies with temperature. For accurate calculation, please enter the temperature at the time of shooting.\nSound speed = 331.5 + 0.6 × Temperature(℃)",
            "location_info": "About Location",
            "location_desc": "Location data is obtained from Apple Maps.",
            "gps_accuracy": "GPS accuracy may include errors of several meters",
            "network_requirement": "Internet connection is required to retrieve map data",

            // Share Text
            "share_text": "KAMURO - Firework Shooting Location Calculator\n#KAMURO #Fireworks",

            // Version
            "version": "Version 1.0",
        ],
        .chineseSimplified: [
            // Common
            "app_name": "KAMURO",
            "input": "输入",
            "ok": "确定",
            "cancel": "取消",
            "close": "关闭",
            "error_title": "错误",
            "settings": "设置",

            // Operation Screen
            "launch_point": "发射地点",
            "select_on_map": "在地图上选择",
            "use_current_location": "使用当前位置",
            "not_selected": "未选择",
            "latitude_format": "纬度: %.6f",
            "longitude_format": "经度: %.6f",

            // Time Difference Input
            "time_difference": "时间差",
            "time_lag_seconds": "时间延迟（秒）",
            "temperature_celsius": "温度（℃）",
            "temperature_info": "输入准确的温度以进行更精确的距离计算",

            // Calculation Result
            "calculate": "计算",
            "calculation_result": "计算结果",
            "distance_format": "距离: 约%.0fm",
            "distance_meters": "约%.0fm",
            "view_on_map": "在地图上显示",
            "map_with_circle": "距离圆显示",
            "circle_description": "显示从发射地点到计算距离的圆",

            // Map Search
            "search_location": "搜索位置",
            "confirm_location": "确认此位置",

            // Settings Screen
            "language": "语言",
            "information": "信息",
            "version_info": "版本信息",
            "about_app": "关于此应用",
            "specification": "规格",
            "notice_title": "使用注意事项",
            "share": "分享",
            "rate_app": "评价应用",

            // About App
            "app_description": "这是一个通过烟花声音反推拍摄位置的应用。通过看到烟花绽放的时刻与听到声音的时刻之差，计算拍摄地点与发射地点的距离。",
            "sound_speed_info": "关于音速",
            "sound_speed_desc": "音速随温度变化。为了精确计算，请输入拍摄时的温度。\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "关于位置信息",
            "location_desc": "位置信息从Apple Maps获取。",
            "gps_accuracy": "GPS精度可能包含几米的误差",
            "network_requirement": "需要互联网连接以获取地图数据",

            // Share Text
            "share_text": "KAMURO - 烟花拍摄位置计算应用\n#KAMURO #烟花",

            // Version
            "version": "版本 1.0",
        ],
        .chineseTaiwan: [
            // Common
            "app_name": "KAMURO",
            "input": "輸入",
            "ok": "確定",
            "cancel": "取消",
            "close": "關閉",
            "error_title": "錯誤",
            "settings": "設定",

            // Operation Screen
            "launch_point": "發射地點",
            "select_on_map": "在地圖上選擇",
            "use_current_location": "使用目前位置",
            "not_selected": "未選擇",
            "latitude_format": "緯度: %.6f",
            "longitude_format": "經度: %.6f",

            // Time Difference Input
            "time_difference": "時間差",
            "time_lag_seconds": "時間延遲（秒）",
            "temperature_celsius": "溫度（℃）",
            "temperature_info": "輸入準確的溫度以進行更精確的距離計算",

            // Calculation Result
            "calculate": "計算",
            "calculation_result": "計算結果",
            "distance_format": "距離: 約%.0fm",
            "distance_meters": "約%.0fm",
            "view_on_map": "在地圖上顯示",
            "map_with_circle": "距離圓顯示",
            "circle_description": "顯示從發射地點到計算距離的圓",

            // Map Search
            "search_location": "搜尋位置",
            "confirm_location": "確認此位置",

            // Settings Screen
            "language": "語言",
            "information": "資訊",
            "version_info": "版本資訊",
            "about_app": "關於此應用",
            "specification": "規格",
            "notice_title": "使用注意事項",
            "share": "分享",
            "rate_app": "評價應用",

            // About App
            "app_description": "這是一個透過煙火聲音反推拍攝位置的應用程式。透過看到煙火綻放的時刻與聽到聲音的時刻之差，計算拍攝地點與發射地點的距離。",
            "sound_speed_info": "關於音速",
            "sound_speed_desc": "音速隨溫度變化。為了精確計算，請輸入拍攝時的溫度。\n音速 = 331.5 + 0.6 × 溫度（℃）",
            "location_info": "關於位置資訊",
            "location_desc": "位置資訊從Apple Maps取得。",
            "gps_accuracy": "GPS精度可能包含數公尺的誤差",
            "network_requirement": "需要網際網路連線以取得地圖資料",

            // Share Text
            "share_text": "KAMURO - 煙火拍攝位置計算應用\n#KAMURO #煙火",

            // Version
            "version": "版本 1.0",
        ],
        .korean: [
            // Common
            "app_name": "KAMURO",
            "input": "입력",
            "ok": "확인",
            "cancel": "취소",
            "close": "닫기",
            "error_title": "오류",
            "settings": "설정",

            // Operation Screen
            "launch_point": "발사 지점",
            "select_on_map": "지도에서 선택",
            "use_current_location": "현재 위치 사용",
            "not_selected": "선택 안 함",
            "latitude_format": "위도: %.6f",
            "longitude_format": "경도: %.6f",

            // Time Difference Input
            "time_difference": "시간 차이",
            "time_lag_seconds": "시간 지연(초)",
            "temperature_celsius": "온도(℃)",
            "temperature_info": "정확한 온도를 입력하면 더 정확한 거리 계산이 가능합니다",

            // Calculation Result
            "calculate": "계산",
            "calculation_result": "계산 결과",
            "distance_format": "거리: 약%.0fm",
            "distance_meters": "약%.0fm",
            "view_on_map": "지도에 표시",
            "map_with_circle": "거리 원 표시",
            "circle_description": "발사 지점부터 계산된 거리의 원을 표시",

            // Map Search
            "search_location": "위치 검색",
            "confirm_location": "이 위치로 확정",

            // Settings Screen
            "language": "언어",
            "information": "정보",
            "version_info": "버전 정보",
            "about_app": "이 앱에 대해",
            "specification": "사양",
            "notice_title": "사용 시 주의사항",
            "share": "공유",
            "rate_app": "앱 평가",

            // About App
            "app_description": "불꽃놀이 소리로부터 촬영 위치를 역산하는 앱입니다. 불꽃이 피어오르는 것을 본 시각과 소리가 들리는 시각의 차이로 촬영 지점과 발사 지점의 거리를 계산합니다.",
            "sound_speed_info": "음속에 대해",
            "sound_speed_desc": "음속은 온도에 따라 변합니다. 정확한 계산을 위해 촬영 시의 온도를 입력해 주세요.\n음속 = 331.5 + 0.6 × 온도(℃)",
            "location_info": "위치 정보에 대해",
            "location_desc": "위치 정보는 Apple Maps에서 가져옵니다.",
            "gps_accuracy": "GPS 정확도에는 수 미터의 오차가 포함될 수 있습니다",
            "network_requirement": "지도 데이터를 가져오려면 인터넷 연결이 필요합니다",

            // Share Text
            "share_text": "KAMURO - 불꽃놀이 촬영 위치 계산 앱\n#KAMURO #불꽃놀이",

            // Version
            "version": "버전 1.0",
        ],
        .spanish: [
            // Common
            "app_name": "KAMURO",
            "input": "Entrada",
            "ok": "OK",
            "cancel": "Cancelar",
            "close": "Cerrar",
            "error_title": "Error",
            "settings": "Configuración",

            // Operation Screen
            "launch_point": "Punto de lanzamiento",
            "select_on_map": "Seleccionar en el mapa",
            "use_current_location": "Usar ubicación actual",
            "not_selected": "No seleccionado",
            "latitude_format": "Latitud: %.6f",
            "longitude_format": "Longitud: %.6f",

            // Time Difference Input
            "time_difference": "Diferencia de tiempo",
            "time_lag_seconds": "Retardo de tiempo (segundos)",
            "temperature_celsius": "Temperatura (℃)",
            "temperature_info": "Ingrese la temperatura precisa para un cálculo de distancia más exacto",

            // Calculation Result
            "calculate": "Calcular",
            "calculation_result": "Resultado del cálculo",
            "distance_format": "Distancia: aprox. %.0fm",
            "distance_meters": "aprox. %.0fm",
            "view_on_map": "Mostrar en el mapa",
            "map_with_circle": "Mostrar círculo de distancia",
            "circle_description": "Mostrar el círculo desde el punto de lanzamiento hasta la distancia calculada",

            // Map Search
            "search_location": "Buscar ubicación",
            "confirm_location": "Confirmar esta ubicación",

            // Settings Screen
            "language": "Idioma",
            "information": "Información",
            "version_info": "Información de versión",
            "about_app": "Acerca de esta aplicación",
            "specification": "Especificación",
            "notice_title": "Notas de uso",
            "share": "Compartir",
            "rate_app": "Calificar aplicación",

            // About App
            "app_description": "Esta es una aplicación que calcula la posición de disparo a partir del sonido de los fuegos artificiales. Calcula la distancia entre el punto de disparo y el punto de lanzamiento a partir de la diferencia entre el momento en que se ve florecer el fuego artificial y el momento en que se escucha el sonido.",
            "sound_speed_info": "Acerca de la velocidad del sonido",
            "sound_speed_desc": "La velocidad del sonido varía con la temperatura. Para un cálculo preciso, ingrese la temperatura en el momento del disparo.\nVelocidad del sonido = 331.5 + 0.6 × Temperatura (℃)",
            "location_info": "Acerca de la información de ubicación",
            "location_desc": "La información de ubicación se obtiene de Apple Maps.",
            "gps_accuracy": "La precisión del GPS puede incluir errores de varios metros",
            "network_requirement": "Se requiere conexión a Internet para recuperar datos del mapa",

            // Share Text
            "share_text": "KAMURO - Aplicación de cálculo de posición de disparo de fuegos artificiales\n#KAMURO #FuegosArtificiales",

            // Version
            "version": "Versión 1.0",
        ],
        .arabic: [
            // Common
            "app_name": "KAMURO",
            "input": "إدخال",
            "ok": "موافق",
            "cancel": "إلغاء",
            "close": "إغلاق",
            "error_title": "خطأ",
            "settings": "الإعدادات",

            // Operation Screen
            "launch_point": "نقطة الإطلاق",
            "select_on_map": "حدد على الخريطة",
            "use_current_location": "استخدم الموقع الحالي",
            "not_selected": "غير محدد",
            "latitude_format": "خط العرض: %.6f",
            "longitude_format": "خط الطول: %.6f",

            // Time Difference Input
            "time_difference": "فرق الوقت",
            "time_lag_seconds": "التأخير الزمني (ثواني)",
            "temperature_celsius": "درجة الحرارة (℃)",
            "temperature_info": "أدخل درجة الحرارة الدقيقة لحساب المسافة بشكل أكثر دقة",

            // Calculation Result
            "calculate": "احسب",
            "calculation_result": "نتيجة الحساب",
            "distance_format": "المسافة: تقريبًا %.0fم",
            "distance_meters": "تقريبًا %.0fم",
            "view_on_map": "عرض على الخريطة",
            "map_with_circle": "عرض دائرة المسافة",
            "circle_description": "عرض دائرة من نقطة الإطلاق بالمسافة المحسوبة",

            // Map Search
            "search_location": "بحث عن موقع",
            "confirm_location": "تأكيد هذا الموقع",

            // Settings Screen
            "language": "اللغة",
            "information": "معلومات",
            "version_info": "معلومات الإصدار",
            "about_app": "حول التطبيق",
            "specification": "المواصفات",
            "notice_title": "ملاحظات الاستخدام",
            "share": "مشاركة",
            "rate_app": "تقييم التطبيق",

            // About App
            "app_description": "هذا تطبيق يحسب موقع التصوير من صوت الألعاب النارية. يحسب المسافة بين نقطة التصوير ونقطة الإطلاق من الفرق الزمني بين رؤية ازدهار الألعاب النارية وسماع الصوت.",
            "sound_speed_info": "حول سرعة الصوت",
            "sound_speed_desc": "تختلف سرعة الصوت باختلاف درجة الحرارة. للحساب الدقيق، يرجى إدخال درجة الحرارة وقت التصوير.\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "حول معلومات الموقع",
            "location_desc": "يتم الحصول على معلومات الموقع من Apple Maps.",
            "gps_accuracy": "قد تتضمن دقة نظام تحديد المواقع العالمي (GPS) أخطاء تصل إلى عدة أمتار",
            "network_requirement": "يلزم الاتصال بالإنترنت لاسترداد بيانات الخريطة",

            // Share Text
            "share_text": "KAMURO - تطبيق حساب موقع تصوير الألعاب النارية\n#KAMURO #الألعاب_النارية",

            // Version
            "version": "الإصدار 1.0",
        ],
        .indonesian: [
            // Common
            "app_name": "KAMURO",
            "input": "Masukan",
            "ok": "OK",
            "cancel": "Batal",
            "close": "Tutup",
            "error_title": "Kesalahan",
            "settings": "Pengaturan",

            // Operation Screen
            "launch_point": "Titik Peluncuran",
            "select_on_map": "Pilih di Peta",
            "use_current_location": "Gunakan Lokasi Saat Ini",
            "not_selected": "Belum Dipilih",
            "latitude_format": "Lintang: %.6f",
            "longitude_format": "Bujur: %.6f",

            // Time Difference Input
            "time_difference": "Perbedaan Waktu",
            "time_lag_seconds": "Keterlambatan Waktu (detik)",
            "temperature_celsius": "Suhu (℃)",
            "temperature_info": "Masukkan suhu yang akurat untuk perhitungan jarak yang lebih presisi",

            // Calculation Result
            "calculate": "Hitung",
            "calculation_result": "Hasil Perhitungan",
            "distance_format": "Jarak: sekitar %.0fm",
            "distance_meters": "sekitar %.0fm",
            "view_on_map": "Tampilkan di Peta",
            "map_with_circle": "Tampilan Lingkaran Jarak",
            "circle_description": "Menampilkan lingkaran dari titik peluncuran dengan jarak yang dihitung",

            // Map Search
            "search_location": "Cari Lokasi",
            "confirm_location": "Konfirmasi Lokasi Ini",

            // Settings Screen
            "language": "Bahasa",
            "information": "Informasi",
            "version_info": "Info Versi",
            "about_app": "Tentang Aplikasi",
            "specification": "Spesifikasi",
            "notice_title": "Catatan Penggunaan",
            "share": "Bagikan",
            "rate_app": "Nilai Aplikasi",

            // About App
            "app_description": "Ini adalah aplikasi yang menghitung posisi pemotretan dari suara kembang api. Menghitung jarak antara titik pemotretan dan titik peluncuran dari perbedaan waktu antara melihat kembang api mekar dan mendengar suaranya.",
            "sound_speed_info": "Tentang Kecepatan Suara",
            "sound_speed_desc": "Kecepatan suara bervariasi dengan suhu. Untuk perhitungan yang akurat, silakan masukkan suhu saat pemotretan.\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "Tentang Informasi Lokasi",
            "location_desc": "Informasi lokasi diperoleh dari Apple Maps.",
            "gps_accuracy": "Akurasi GPS mungkin mengandung kesalahan beberapa meter",
            "network_requirement": "Koneksi internet diperlukan untuk mengambil data peta",

            // Share Text
            "share_text": "KAMURO - Aplikasi Kalkulator Posisi Pemotretan Kembang Api\n#KAMURO #KembangApi",

            // Version
            "version": "Versi 1.0",
        ],
        .malay: [
            // Common
            "app_name": "KAMURO",
            "input": "Input",
            "ok": "OK",
            "cancel": "Batal",
            "close": "Tutup",
            "error_title": "Ralat",
            "settings": "Tetapan",

            // Operation Screen
            "launch_point": "Titik Pelancar",
            "select_on_map": "Pilih di Peta",
            "use_current_location": "Guna Lokasi Semasa",
            "not_selected": "Tidak Dipilih",
            "latitude_format": "Latitud: %.6f",
            "longitude_format": "Longitud: %.6f",

            // Time Difference Input
            "time_difference": "Perbezaan Masa",
            "time_lag_seconds": "Kelewatan Masa (saat)",
            "temperature_celsius": "Suhu (℃)",
            "temperature_info": "Masukkan suhu yang tepat untuk pengiraan jarak yang lebih tepat",

            // Calculation Result
            "calculate": "Kira",
            "calculation_result": "Hasil Pengiraan",
            "distance_format": "Jarak: kira-kira %.0fm",
            "distance_meters": "kira-kira %.0fm",
            "view_on_map": "Papar di Peta",
            "map_with_circle": "Paparan Bulatan Jarak",
            "circle_description": "Paparkan bulatan dari titik pelancar dengan jarak yang dikira",

            // Map Search
            "search_location": "Cari Lokasi",
            "confirm_location": "Sahkan Lokasi Ini",

            // Settings Screen
            "language": "Bahasa",
            "information": "Maklumat",
            "version_info": "Maklumat Versi",
            "about_app": "Tentang Aplikasi",
            "specification": "Spesifikasi",
            "notice_title": "Nota Penggunaan",
            "share": "Kongsi",
            "rate_app": "Nilai Aplikasi",

            // About App
            "app_description": "Ini adalah aplikasi yang mengira kedudukan penggambaran daripada bunyi bunga api. Mengira jarak antara titik penggambaran dan titik pelancar daripada perbezaan masa antara melihat bunga api mekar dan mendengar bunyinya.",
            "sound_speed_info": "Tentang Kelajuan Bunyi",
            "sound_speed_desc": "Kelajuan bunyi berbeza mengikut suhu. Untuk pengiraan yang tepat, sila masukkan suhu semasa penggambaran.\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "Tentang Maklumat Lokasi",
            "location_desc": "Maklumat lokasi diperoleh daripada Apple Maps.",
            "gps_accuracy": "Ketepatan GPS mungkin mengandungi ralat beberapa meter",
            "network_requirement": "Sambungan internet diperlukan untuk mendapatkan data peta",

            // Share Text
            "share_text": "KAMURO - Aplikasi Pengiraan Kedudukan Penggambaran Bunga Api\n#KAMURO #BungaApi",

            // Version
            "version": "Versi 1.0",
        ],
        .portuguese: [
            // Common
            "app_name": "KAMURO",
            "input": "Entrada",
            "ok": "OK",
            "cancel": "Cancelar",
            "close": "Fechar",
            "error_title": "Erro",
            "settings": "Configurações",

            // Operation Screen
            "launch_point": "Ponto de Lançamento",
            "select_on_map": "Selecionar no Mapa",
            "use_current_location": "Usar Localização Atual",
            "not_selected": "Não Selecionado",
            "latitude_format": "Latitude: %.6f",
            "longitude_format": "Longitude: %.6f",

            // Time Difference Input
            "time_difference": "Diferença de Tempo",
            "time_lag_seconds": "Atraso de Tempo (segundos)",
            "temperature_celsius": "Temperatura (℃)",
            "temperature_info": "Insira a temperatura precisa para um cálculo de distância mais exato",

            // Calculation Result
            "calculate": "Calcular",
            "calculation_result": "Resultado do Cálculo",
            "distance_format": "Distância: aprox. %.0fm",
            "distance_meters": "aprox. %.0fm",
            "view_on_map": "Visualizar no Mapa",
            "map_with_circle": "Exibição do Círculo de Distância",
            "circle_description": "Exibe o círculo do ponto de lançamento até a distância calculada",

            // Map Search
            "search_location": "Pesquisar Localização",
            "confirm_location": "Confirmar Esta Localização",

            // Settings Screen
            "language": "Idioma",
            "information": "Informação",
            "version_info": "Informações da Versão",
            "about_app": "Sobre o Aplicativo",
            "specification": "Especificação",
            "notice_title": "Notas de Uso",
            "share": "Compartilhar",
            "rate_app": "Avaliar Aplicativo",

            // About App
            "app_description": "Este é um aplicativo que calcula a posição de captura a partir do som dos fogos de artifício. Calcula a distância entre o ponto de captura e o ponto de lançamento a partir da diferença de tempo entre ver o fogo de artifício florescer e ouvir o som.",
            "sound_speed_info": "Sobre a Velocidade do Som",
            "sound_speed_desc": "A velocidade do som varia com a temperatura. Para um cálculo preciso, insira a temperatura no momento da captura.\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "Sobre Informações de Localização",
            "location_desc": "As informações de localização são obtidas do Apple Maps.",
            "gps_accuracy": "A precisão do GPS pode incluir erros de vários metros",
            "network_requirement": "Conexão com a internet é necessária para recuperar dados do mapa",

            // Share Text
            "share_text": "KAMURO - Aplicativo de Cálculo de Posição de Captura de Fogos de Artifício\n#KAMURO #FogosDeArtifício",

            // Version
            "version": "Versão 1.0",
        ],
        .french: [
            // Common
            "app_name": "KAMURO",
            "input": "Entrée",
            "ok": "OK",
            "cancel": "Annuler",
            "close": "Fermer",
            "error_title": "Erreur",
            "settings": "Paramètres",

            // Operation Screen
            "launch_point": "Point de Lancement",
            "select_on_map": "Sélectionner sur la Carte",
            "use_current_location": "Utiliser la Position Actuelle",
            "not_selected": "Non Sélectionné",
            "latitude_format": "Latitude: %.6f",
            "longitude_format": "Longitude: %.6f",

            // Time Difference Input
            "time_difference": "Différence de Temps",
            "time_lag_seconds": "Décalage Temporel (secondes)",
            "temperature_celsius": "Température (℃)",
            "temperature_info": "Entrez la température précise pour un calcul de distance plus exact",

            // Calculation Result
            "calculate": "Calculer",
            "calculation_result": "Résultat du Calcul",
            "distance_format": "Distance: environ %.0fm",
            "distance_meters": "environ %.0fm",
            "view_on_map": "Afficher sur la Carte",
            "map_with_circle": "Affichage du Cercle de Distance",
            "circle_description": "Affiche le cercle du point de lancement à la distance calculée",

            // Map Search
            "search_location": "Rechercher un Lieu",
            "confirm_location": "Confirmer ce Lieu",

            // Settings Screen
            "language": "Langue",
            "information": "Information",
            "version_info": "Informations sur la Version",
            "about_app": "À Propos de l'Application",
            "specification": "Spécification",
            "notice_title": "Notes d'Utilisation",
            "share": "Partager",
            "rate_app": "Évaluer l'Application",

            // About App
            "app_description": "Cette application calcule la position de prise de vue à partir du son des feux d'artifice. Elle calcule la distance entre le point de prise de vue et le point de lancement à partir de la différence de temps entre la vision de l'éclosion du feu d'artifice et l'audition du son.",
            "sound_speed_info": "À Propos de la Vitesse du Son",
            "sound_speed_desc": "La vitesse du son varie en fonction de la température. Pour un calcul précis, veuillez entrer la température au moment de la prise de vue.\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "À Propos des Informations de Localisation",
            "location_desc": "Les informations de localisation sont obtenues depuis Apple Maps.",
            "gps_accuracy": "La précision GPS peut inclure des erreurs de plusieurs mètres",
            "network_requirement": "Une connexion Internet est nécessaire pour récupérer les données de la carte",

            // Share Text
            "share_text": "KAMURO - Application de Calcul de Position de Prise de Vue de Feux d'Artifice\n#KAMURO #FeuxDArtifice",

            // Version
            "version": "Version 1.0",
        ],
        .german: [
            // Common
            "app_name": "KAMURO",
            "input": "Eingabe",
            "ok": "OK",
            "cancel": "Abbrechen",
            "close": "Schließen",
            "error_title": "Fehler",
            "settings": "Einstellungen",

            // Operation Screen
            "launch_point": "Startpunkt",
            "select_on_map": "Auf Karte Auswählen",
            "use_current_location": "Aktuellen Standort Verwenden",
            "not_selected": "Nicht Ausgewählt",
            "latitude_format": "Breitengrad: %.6f",
            "longitude_format": "Längengrad: %.6f",

            // Time Difference Input
            "time_difference": "Zeitunterschied",
            "time_lag_seconds": "Zeitverzögerung (Sekunden)",
            "temperature_celsius": "Temperatur (℃)",
            "temperature_info": "Geben Sie die genaue Temperatur für eine präzisere Entfernungsberechnung ein",

            // Calculation Result
            "calculate": "Berechnen",
            "calculation_result": "Berechnungsergebnis",
            "distance_format": "Entfernung: ca. %.0fm",
            "distance_meters": "ca. %.0fm",
            "view_on_map": "Auf Karte Anzeigen",
            "map_with_circle": "Entfernungskreis-Anzeige",
            "circle_description": "Zeigt den Kreis vom Startpunkt bis zur berechneten Entfernung an",

            // Map Search
            "search_location": "Standort Suchen",
            "confirm_location": "Diesen Standort Bestätigen",

            // Settings Screen
            "language": "Sprache",
            "information": "Information",
            "version_info": "Versionsinformationen",
            "about_app": "Über die App",
            "specification": "Spezifikation",
            "notice_title": "Nutzungshinweise",
            "share": "Teilen",
            "rate_app": "App Bewerten",

            // About App
            "app_description": "Dies ist eine App, die die Aufnahmeposition aus dem Klang von Feuerwerken berechnet. Sie berechnet die Entfernung zwischen Aufnahmepunkt und Startpunkt aus der Zeitdifferenz zwischen dem Sehen der Feuerwerksblüte und dem Hören des Klangs.",
            "sound_speed_info": "Über die Schallgeschwindigkeit",
            "sound_speed_desc": "Die Schallgeschwindigkeit variiert mit der Temperatur. Für eine genaue Berechnung geben Sie bitte die Temperatur zum Zeitpunkt der Aufnahme ein.\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "Über Standortinformationen",
            "location_desc": "Standortinformationen werden von Apple Maps abgerufen.",
            "gps_accuracy": "Die GPS-Genauigkeit kann Fehler von mehreren Metern enthalten",
            "network_requirement": "Internetverbindung ist erforderlich, um Kartendaten abzurufen",

            // Share Text
            "share_text": "KAMURO - Feuerwerk-Aufnahmepositions-Rechner-App\n#KAMURO #Feuerwerk",

            // Version
            "version": "Version 1.0",
        ],
        .italian: [
            // Common
            "app_name": "KAMURO",
            "input": "Ingresso",
            "ok": "OK",
            "cancel": "Annulla",
            "close": "Chiudi",
            "error_title": "Errore",
            "settings": "Impostazioni",

            // Operation Screen
            "launch_point": "Punto di Lancio",
            "select_on_map": "Seleziona sulla Mappa",
            "use_current_location": "Usa Posizione Attuale",
            "not_selected": "Non Selezionato",
            "latitude_format": "Latitudine: %.6f",
            "longitude_format": "Longitudine: %.6f",

            // Time Difference Input
            "time_difference": "Differenza di Tempo",
            "time_lag_seconds": "Ritardo Temporale (secondi)",
            "temperature_celsius": "Temperatura (℃)",
            "temperature_info": "Inserisci la temperatura precisa per un calcolo della distanza più accurato",

            // Calculation Result
            "calculate": "Calcola",
            "calculation_result": "Risultato del Calcolo",
            "distance_format": "Distanza: circa %.0fm",
            "distance_meters": "circa %.0fm",
            "view_on_map": "Visualizza sulla Mappa",
            "map_with_circle": "Visualizzazione Cerchio di Distanza",
            "circle_description": "Visualizza il cerchio dal punto di lancio alla distanza calcolata",

            // Map Search
            "search_location": "Cerca Posizione",
            "confirm_location": "Conferma Questa Posizione",

            // Settings Screen
            "language": "Lingua",
            "information": "Informazioni",
            "version_info": "Informazioni sulla Versione",
            "about_app": "Informazioni sull'App",
            "specification": "Specifiche",
            "notice_title": "Note sull'Utilizzo",
            "share": "Condividi",
            "rate_app": "Valuta l'App",

            // About App
            "app_description": "Questa è un'app che calcola la posizione di ripresa dal suono dei fuochi d'artificio. Calcola la distanza tra il punto di ripresa e il punto di lancio dalla differenza di tempo tra la visione della fioritura dei fuochi d'artificio e l'ascolto del suono.",
            "sound_speed_info": "Informazioni sulla Velocità del Suono",
            "sound_speed_desc": "La velocità del suono varia con la temperatura. Per un calcolo accurato, inserisci la temperatura al momento della ripresa.\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "Informazioni sulla Posizione",
            "location_desc": "Le informazioni sulla posizione vengono ottenute da Apple Maps.",
            "gps_accuracy": "La precisione GPS può includere errori di diversi metri",
            "network_requirement": "È richiesta la connessione Internet per recuperare i dati della mappa",

            // Share Text
            "share_text": "KAMURO - App Calcolatore Posizione di Ripresa Fuochi d'Artificio\n#KAMURO #FuochiDArtificio",

            // Version
            "version": "Versione 1.0",
        ],
        .vietnamese: [
            // Common
            "app_name": "KAMURO",
            "input": "Nhập",
            "ok": "OK",
            "cancel": "Hủy",
            "close": "Đóng",
            "error_title": "Lỗi",
            "settings": "Cài đặt",

            // Operation Screen
            "launch_point": "Điểm Phóng",
            "select_on_map": "Chọn trên Bản đồ",
            "use_current_location": "Sử dụng Vị trí Hiện tại",
            "not_selected": "Chưa Chọn",
            "latitude_format": "Vĩ độ: %.6f",
            "longitude_format": "Kinh độ: %.6f",

            // Time Difference Input
            "time_difference": "Chênh lệch Thời gian",
            "time_lag_seconds": "Độ trễ Thời gian (giây)",
            "temperature_celsius": "Nhiệt độ (℃)",
            "temperature_info": "Nhập nhiệt độ chính xác để tính toán khoảng cách chính xác hơn",

            // Calculation Result
            "calculate": "Tính toán",
            "calculation_result": "Kết quả Tính toán",
            "distance_format": "Khoảng cách: khoảng %.0fm",
            "distance_meters": "khoảng %.0fm",
            "view_on_map": "Xem trên Bản đồ",
            "map_with_circle": "Hiển thị Vòng tròn Khoảng cách",
            "circle_description": "Hiển thị vòng tròn từ điểm phóng đến khoảng cách được tính toán",

            // Map Search
            "search_location": "Tìm kiếm Vị trí",
            "confirm_location": "Xác nhận Vị trí Này",

            // Settings Screen
            "language": "Ngôn ngữ",
            "information": "Thông tin",
            "version_info": "Thông tin Phiên bản",
            "about_app": "Về Ứng dụng",
            "specification": "Thông số kỹ thuật",
            "notice_title": "Lưu ý Sử dụng",
            "share": "Chia sẻ",
            "rate_app": "Đánh giá Ứng dụng",

            // About App
            "app_description": "Đây là ứng dụng tính toán vị trí chụp từ âm thanh pháo hoa. Tính toán khoảng cách giữa điểm chụp và điểm phóng từ chênh lệch thời gian giữa việc nhìn thấy pháo hoa nở và nghe thấy âm thanh.",
            "sound_speed_info": "Về Tốc độ Âm thanh",
            "sound_speed_desc": "Tốc độ âm thanh thay đổi theo nhiệt độ. Để tính toán chính xác, vui lòng nhập nhiệt độ tại thời điểm chụp.\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "Về Thông tin Vị trí",
            "location_desc": "Thông tin vị trí được lấy từ Apple Maps.",
            "gps_accuracy": "Độ chính xác GPS có thể bao gồm sai số vài mét",
            "network_requirement": "Cần kết nối Internet để truy xuất dữ liệu bản đồ",

            // Share Text
            "share_text": "KAMURO - Ứng dụng Tính toán Vị trí Chụp Pháo hoa\n#KAMURO #PháoHoa",

            // Version
            "version": "Phiên bản 1.0",
        ],
        .thai: [
            // Common
            "app_name": "KAMURO",
            "input": "ป้อนข้อมูล",
            "ok": "ตกลง",
            "cancel": "ยกเลิก",
            "close": "ปิด",
            "error_title": "ข้อผิดพลาด",
            "settings": "การตั้งค่า",

            // Operation Screen
            "launch_point": "จุดปล่อย",
            "select_on_map": "เลือกบนแผนที่",
            "use_current_location": "ใช้ตำแหน่งปัจจุบัน",
            "not_selected": "ยังไม่ได้เลือก",
            "latitude_format": "ละติจูด: %.6f",
            "longitude_format": "ลองจิจูด: %.6f",

            // Time Difference Input
            "time_difference": "ความแตกต่างของเวลา",
            "time_lag_seconds": "ช่วงเวลาล่าช้า (วินาที)",
            "temperature_celsius": "อุณหภูมิ (℃)",
            "temperature_info": "ป้อนอุณหภูมิที่แม่นยำเพื่อการคำนวณระยะทางที่แม่นยำยิ่งขึ้น",

            // Calculation Result
            "calculate": "คำนวณ",
            "calculation_result": "ผลการคำนวณ",
            "distance_format": "ระยะทาง: ประมาณ %.0fm",
            "distance_meters": "ประมาณ %.0fm",
            "view_on_map": "แสดงบนแผนที่",
            "map_with_circle": "แสดงวงกลมระยะทาง",
            "circle_description": "แสดงวงกลมจากจุดปล่อยถึงระยะทางที่คำนวณได้",

            // Map Search
            "search_location": "ค้นหาตำแหน่ง",
            "confirm_location": "ยืนยันตำแหน่งนี้",

            // Settings Screen
            "language": "ภาษา",
            "information": "ข้อมูล",
            "version_info": "ข้อมูลเวอร์ชัน",
            "about_app": "เกี่ยวกับแอป",
            "specification": "ข้อมูลจำเพาะ",
            "notice_title": "ข้อควรระวังในการใช้งาน",
            "share": "แชร์",
            "rate_app": "ให้คะแนนแอป",

            // About App
            "app_description": "แอปนี้คำนวณตำแหน่งการถ่ายภาพจากเสียงดอกไม้ไฟ คำนวณระยะทางระหว่างจุดถ่ายภาพและจุดปล่อยจากความแตกต่างของเวลาระหว่างการมองเห็นดอกไม้ไฟบานและการได้ยินเสียง",
            "sound_speed_info": "เกี่ยวกับความเร็วเสียง",
            "sound_speed_desc": "ความเร็วเสียงแตกต่างกันตามอุณหภูมิ สำหรับการคำนวณที่แม่นยำ โปรดป้อนอุณหภูมิในขณะถ่ายภาพ\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "เกี่ยวกับข้อมูลตำแหน่ง",
            "location_desc": "ข้อมูลตำแหน่งได้มาจาก Apple Maps",
            "gps_accuracy": "ความแม่นยำของ GPS อาจมีข้อผิดพลาดหลายเมตร",
            "network_requirement": "ต้องการการเชื่อมต่ออินเทอร์เน็ตเพื่อดึงข้อมูลแผนที่",

            // Share Text
            "share_text": "KAMURO - แอปคำนวณตำแหน่งการถ่ายภาพดอกไม้ไฟ\n#KAMURO #ดอกไม้ไฟ",

            // Version
            "version": "เวอร์ชัน 1.0",
        ],
        .burmese: [
            // Common
            "app_name": "KAMURO",
            "input": "ထည့်သွင်းခြင်း",
            "ok": "OK",
            "cancel": "ပယ်ဖျက်ရန်",
            "close": "ပိတ်ရန်",
            "error_title": "အမှား",
            "settings": "ဆက်တင်များ",

            // Operation Screen
            "launch_point": "လွှတ်တင်သည့်နေရာ",
            "select_on_map": "မြေပုံပေါ်တွင် ရွေးချယ်ပါ",
            "use_current_location": "လက်ရှိတည်နေရာကို အသုံးပြုပါ",
            "not_selected": "ရွေးမထားပါ",
            "latitude_format": "လတ္တီကျု: %.6f",
            "longitude_format": "လောင်ဂျီကျု: %.6f",

            // Time Difference Input
            "time_difference": "အချိန်ခြားနားချက်",
            "time_lag_seconds": "အချိန်နောက်ကျမှု (စက္ကန့်)",
            "temperature_celsius": "အပူချိန် (℃)",
            "temperature_info": "ပိုမိုတိကျသော အကွာအဝေးတွက်ချက်မှုအတွက် တိကျသော အပူချိန်ကို ထည့်သွင်းပါ",

            // Calculation Result
            "calculate": "တွက်ချက်ရန်",
            "calculation_result": "တွက်ချက်မှုရလဒ်",
            "distance_format": "အကွာအဝေး: ခန့်မှန်းခြေ %.0fm",
            "distance_meters": "ခန့်မှန်းခြေ %.0fm",
            "view_on_map": "မြေပုံပေါ်တွင် ကြည့်ရန်",
            "map_with_circle": "အကွာအဝေး စက်ဝိုင်းပြသခြင်း",
            "circle_description": "လွှတ်တင်သည့်နေရာမှ တွက်ချက်ထားသော အကွာအဝေးအထိ စက်ဝိုင်းပြသပါ",

            // Map Search
            "search_location": "တည်နေရာရှာဖွေရန်",
            "confirm_location": "ဤတည်နေရာကို အတည်ပြုပါ",

            // Settings Screen
            "language": "ဘာသာစကား",
            "information": "သတင်းအချက်အလက်",
            "version_info": "ဗားရှင်းအချက်အလက်",
            "about_app": "အက်ပ်အကြောင်း",
            "specification": "သတ်မှတ်ချက်",
            "notice_title": "အသုံးပြုမှုမှတ်ချက်များ",
            "share": "မျှဝေရန်",
            "rate_app": "အက်ပ်အား အဆင့်သတ်မှတ်ရန်",

            // About App
            "app_description": "ဤအက်ပ်သည် မီးပန်းအသံမှ ဓာတ်ပုံရိုက်ကူးသည့်နေရာကို တွက်ချက်ပေးသည်။ မီးပန်းပွင့်တာကို မြင်သည့်အချိန်နှင့် အသံကြားသည့်အချိန်ကြား ကွာခြားချက်မှ ရိုက်ကူးသည့်နေရာနှင့် လွှတ်တင်သည့်နေရာကြား အကွာအဝေးကို တွက်ချက်ပေးသည်။",
            "sound_speed_info": "အသံအမြန်နှုန်းအကြောင်း",
            "sound_speed_desc": "အသံအမြန်နှုန်းသည် အပူချိန်အရ ပြောင်းလဲသည်။ တိကျသော တွက်ချက်မှုအတွက် ရိုက်ကူးစဉ် အပူချိန်ကို ထည့်သွင်းပါ။\n音速 = 331.5 + 0.6 × 温度（℃）",
            "location_info": "တည်နေရာအချက်အလက်အကြောင်း",
            "location_desc": "တည်နေရာအချက်အလက်များကို Apple Maps မှ ရယူပါသည်။",
            "gps_accuracy": "GPS တိကျမှုတွင် မီတာအနည်းငယ် အမှားအယွင်းများ ပါဝင်နိုင်သည်",
            "network_requirement": "မြေပုံဒေတာရယူရန် အင်တာနက်ချိတ်ဆက်မှု လိုအပ်ပါသည်",

            // Share Text
            "share_text": "KAMURO - မီးပန်းရိုက်ကူးသည့်နေရာ တွက်ချက်ပေးသည့်အက်ပ်\n#KAMURO #မီးပန်း",

            // Version
            "version": "ဗားရှင်း 1.0",
        ]
    ]

    // 初期化 - UserDefaultsから保存された言語設定を読み込む
    init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // デフォルトは日本語
            self.currentLanguage = .japanese
        }
    }

    // 指定されたキーのローカライズされた文字列を取得
    func localizedString(for key: String) -> String {
        return translations[currentLanguage]?[key] ?? key
    }
}
