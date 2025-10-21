# Sistema de alquiler de autos

## 1. Reconstruir el proyecto Android

```bash
flutter create --platforms=android --empty .
```

**Descripción:**  
Este comando **recrea la estructura base** del proyecto Flutter en el directorio actual (`.`), **solo para la plataforma Android**, sin generar los archivos predeterminados de ejemplo.

---

## 2. Ejecutar la aplicación en modo debug

```bash
flutter run
```

**Descripción:**  
Compila y ejecuta la aplicación Flutter en un **dispositivo físico o emulador conectado**.

---

## 3. Generar el archivo APK instalable

```bash
flutter build apk
```

**Descripción:**  
Compila la aplicación en **modo release** y genera un archivo `.apk` listo para instalar manualmente en un dispositivo Android.

**Ubicación del APK generado:**  
```
build/app/outputs/apk/app-release.apk
```
