# 🌊 Smart IoT Master

<div align="center">
  <img src="icon.png" alt="Smart IoT Master Logo" width="120" height="120" style="border-radius: 25px;">
  
  **A comprehensive IoT monitoring solution for smart water tank management**
  
  [![Made in India](https://img.shields.io/badge/Made%20in-India-orange?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjgiIGZpbGw9IiNGRjk5MzMiLz4KPHJlY3QgeT0iOCIgd2lkdGg9IjI0IiBoZWlnaHQ9IjgiIGZpbGw9IiNGRkZGRkYiLz4KPHJlY3QgeT0iMTYiIHdpZHRoPSIyNCIgaGVpZ2h0PSI4IiBmaWxsPSIjMTM4ODA4Ii8+Cjwvc3ZnPgo=)](https://github.com/kunalyadav6379-techy)
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  
  ![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=flat-square)
  ![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
  ![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen?style=flat-square)
</div>

---

## 📱 Overview

**Smart IoT Master** is a modern, cross-platform mobile application built with Flutter that provides comprehensive monitoring and control for IoT-based water tank management systems. The app offers real-time monitoring, intelligent alerts, and seamless device control through a beautiful, intuitive interface.

### 🎯 Key Features

- **🌊 Real-time Water Level Monitoring** - Live water level tracking with visual indicators
- **🔔 Smart Buzzer Control** - Remote buzzer management with customizable beep levels
- **📊 System Dashboard** - Comprehensive overview of all connected IoT devices
- **🎛️ NodeMCU Pin Monitoring** - Real-time digital pin status monitoring
- **🌡️ CPU Temperature Tracking** - System health monitoring with temperature alerts
- **⚙️ Trigger Level Management** - Configurable water level trigger thresholds
- **🎨 Dynamic Theming** - Light, Dark, and System theme support with persistence
- **🔧 Debug Console** - Advanced debugging tools for developers
- **📱 Cross-platform** - Works seamlessly on Android, iOS, and Web

---

## 🚀 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="screenshots/home_light.png" width="200" alt="Home Screen Light">
        <br><sub><b>Home Dashboard (Light)</b></sub>
      </td>
      <td align="center">
        <img src="screenshots/home_dark.png" width="200" alt="Home Screen Dark">
        <br><sub><b>Home Dashboard (Dark)</b></sub>
      </td>
      <td align="center">
        <img src="screenshots/settings.png" width="200" alt="Settings Screen">
        <br><sub><b>Settings & Controls</b></sub>
      </td>
    </tr>
    <tr>
      <td align="center">
        <img src="screenshots/nodemcu_pins.png" width="200" alt="NodeMCU Pins">
        <br><sub><b>NodeMCU Pin Status</b></sub>
      </td>
      <td align="center">
        <img src="screenshots/system_monitor.png" width="200" alt="System Monitor">
        <br><sub><b>System Monitoring</b></sub>
      </td>
      <td align="center">
        <img src="screenshots/debug_console.png" width="200" alt="Debug Console">
        <br><sub><b>Debug Console</b></sub>
      </td>
    </tr>
  </table>
</div>

---

## 🏗️ Architecture

### 📋 Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider Pattern
- **HTTP Client**: Dart HTTP Package
- **Local Storage**: SharedPreferences
- **UI Framework**: Cupertino (iOS-style) + Material Design
- **Architecture**: Clean Architecture with Provider

### 🔧 System Components

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├─────────────────────────────────────────────────────────┤
│  📱 UI Layer (Screens & Widgets)                       │
│  ├── Home Dashboard                                     │
│  ├── System Monitor                                     │
│  ├── Settings & Controls                                │
│  └── Debug Console                                      │
├─────────────────────────────────────────────────────────┤
│  🧠 Business Logic (Providers & Services)              │
│  ├── Theme Provider                                     │
│  ├── API Service                                        │
│  └── Data Models                                        │
├─────────────────────────────────────────────────────────┤
│  🌐 Network Layer                                       │
│  ├── HTTP Client                                        │
│  ├── API Endpoints                                      │
│  └── Error Handling                                     │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                 IoT Hardware Layer                      │
├─────────────────────────────────────────────────────────┤
│  🔌 NodeMCU ESP8266                                     │
│  ├── Digital Pins (D5, D6, D7)                         │
│  ├── Water Level Sensor                                 │
│  ├── Buzzer Control                                     │
│  └── Temperature Monitoring                             │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ Installation & Setup

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Git

### 📥 Clone Repository

```bash
git clone https://github.com/kunalyadav6379-techy/Smart-IoT-Master.git
cd Smart-IoT-Master
```

### 📦 Install Dependencies

```bash
flutter pub get
```

### 🔧 Configuration

1. **API Endpoints**: Update the base URLs in `lib/services/api_service.dart`
```dart
static const String baseUrl = 'http://YOUR_IOT_DEVICE_IP:5001';
```

2. **Hardware Setup**: Configure your NodeMCU ESP8266 with the following endpoints:
   - Water Level: `/pin/V3`
   - Buzzer Control: `/update/V1`
   - Digital Pins: `/pin/V5`, `/pin/V6`, `/pin/V7`
   - CPU Temperature: `/cpu/temperature`

### 🚀 Run Application

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Build APK
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## 📡 API Documentation

### 🌊 Water Level API

```http
GET /pin/V3
```

**Response:**
```json
{
  "pin": "V3",
  "value": "75",
  "timestamp": 1640995200,
  "unit": "%"
}
```

### 🔔 Buzzer Control API

```http
GET /update/V1?value={0|1}
```

**Parameters:**
- `value`: 0 (OFF) or 1 (ON)

### 🎛️ Digital Pins API

```http
GET /pin/V{5|6|7}
```

**Response:**
```json
{
  "pin": "V5",
  "value": "1",
  "timestamp": 1640995200
}
```

### 🌡️ CPU Temperature API

```http
GET /cpu/temperature
```

**Response:**
```json
{
  "temperature": 45.2,
  "unit": "°C",
  "status": "normal",
  "timestamp": 1640995200
}
```

---

## 🎨 Features Deep Dive

### 🏠 Home Dashboard
- **Real-time water level visualization** with animated circular progress indicator
- **Current trigger level display** with color-coded status
- **System status monitoring** with online/offline indicators
- **Quick access cards** for essential information

### ⚙️ Settings & Controls
- **Theme Management**: Light, Dark, and Follow System options with persistence
- **Buzzer Beep Level**: Adjustable intensity (0-255) with visual feedback
- **Trigger Level Configuration**: Set water level thresholds (0%, 33%, 66%)
- **Developer Credits**: Clean attribution section

### 🔧 System Monitoring
- **CPU Temperature Tracking** with status indicators (Normal, Warm, Warning, Critical)
- **NodeMCU Pin Status** with real-time updates and caching
- **Connection Status** with smart retry mechanisms
- **Performance Metrics** and system health indicators

### 🐛 Debug Console
- **API Endpoint Testing** with interactive test buttons
- **Debug Tools** for cache management and settings reset
- **Network Diagnostics** for troubleshooting connectivity issues

---

## 🎯 Smart Features

### 🧠 Intelligent Caching
- **Data Persistence**: Maintains last known good data during network issues
- **Smart Retry Logic**: Automatic retry with exponential backoff
- **Offline Resilience**: Graceful degradation when APIs are unavailable

### 🎨 Adaptive UI
- **Theme Persistence**: Remembers user theme preference across app restarts
- **System Theme Integration**: Automatically adapts to device theme changes
- **Responsive Design**: Optimized for various screen sizes and orientations

### 📊 Real-time Updates
- **Live Data Streaming**: 2-second update intervals for critical data
- **Status Indicators**: Visual feedback for connection and data freshness
- **Error Handling**: Comprehensive error management with user-friendly messages

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### 📝 Development Guidelines

- Follow [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Write meaningful commit messages
- Add comments for complex logic
- Test on multiple devices/platforms
- Update documentation for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

<div align="center">
  <img src="https://github.com/kunalyadav6379-techy.png" width="100" height="100" style="border-radius: 50%;">
  
  **Kunal Yadav**
  
  *Software Developer & IoT Enthusiast*
  
  [![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/kunalyadav6379-techy)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/kunalyadav6379)
  [![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:kunalyadav6379@gmail.com)
</div>

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing cross-platform framework
- **Dart Team** for the powerful programming language
- **Open Source Community** for inspiration and resources
- **IoT Community** for hardware integration insights

---

## 📞 Support

If you encounter any issues or have questions:

1. **Check** the [Issues](https://github.com/kunalyadav6379-techy/Smart-IoT-Master/issues) page
2. **Create** a new issue with detailed description
3. **Contact** the developer directly

---

<div align="center">
  <h3>⭐ Star this repository if you found it helpful!</h3>
  
  **Made with ❤️ in India**
  
  ![Visitor Count](https://visitor-badge.laobi.icu/badge?page_id=kunalyadav6379-techy.Smart-IoT-Master)
</div>