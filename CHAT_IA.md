# Chat IA — configuración (lab13boza)

Se agregó una pestaña **Chat IA** que conversa con el modelo `google/gemma-4-26B-A4B-it`
a través de OpenWebUI, con **memoria** (envía todo el historial de la sesión para que la IA
recuerde lo conversado).

## Archivos agregados

```
Models/ChatMessage.swift      # Modelo del mensaje + structs de la API
ViewModels/ChatViewModel.swift # Lógica del chat (async/await, memoria)
View/ChatView.swift           # Pantalla del chat (burbujas + input)
View/MainTabView.swift        # TabView: Usuarios | Chat IA
```

`lab13bozaApp.swift` ahora muestra `MainTabView()` en lugar de `ContentView()`.

## ⚠️ PASO OBLIGATORIO: permitir HTTP (App Transport Security)

La API es `http://192.168.17.11:3000` (HTTP, no HTTPS). iOS **bloquea HTTP por defecto**, así
que la app no podrá conectarse hasta que agregues una excepción.

**Opción A — Desde Xcode (interfaz):**
1. Selecciona el proyecto → tu *target* `lab13boza` → pestaña **Info**.
2. En *Custom iOS Target Properties*, click derecho → **Add Row**.
3. Agrega **App Transport Security Settings** (tipo Dictionary).
4. Dentro, agrega **Allow Arbitrary Loads** = **YES**.

**Opción B — Editando Info.plist (modo código):**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

> Sin este permiso, el chat dará error de conexión (la petición falla en silencio).

## Notas

- Debes estar conectado a la **red cableada del laboratorio** para alcanzar `192.168.17.11`.
- El `apiKey`, la `baseURL` y el `model` están en `ChatViewModel.swift`; cámbialos si tu token
  o tu modelo son distintos.
- Poner la API key dentro de la app es solo para fines del laboratorio; en producción no se hace.
- El botón 🗑️ (arriba a la derecha) limpia la conversación y borra la memoria.
