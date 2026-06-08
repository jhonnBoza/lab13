# Laboratorio 13 — Consumir API desde una aplicación (SwiftUI + MVVM)

**Curso:** Programación de Móviles Avanzados — C24
**Integrantes:** Jaime Gómez · Juan León
**API consumida:** `https://jsonplaceholder.typicode.com/users`

---

## Estructura del proyecto (MVVM)

```
lab13boza/
├── Models/
│   └── User.swift            // Modelo de datos (Codable, Identifiable)
├── ViewModels/
│   └── UserViewModel.swift   // Lógica de red y consumo de la API (CRUD)
├── View/
│   ├── ContentView.swift     // Vista principal: lista, búsqueda, acciones
│   └── UserFormView.swift    // Formulario para agregar / editar usuario
└── lab13bozaApp.swift        // Punto de entrada de la app
```

El código final corresponde a la **Actividad 03**, que evoluciona las Actividades 01 y 02
para usar `URLSession` con `async/await`. Incluye toda la funcionalidad pedida:
listar (GET), buscar/filtrar, agregar (POST), editar (PUT) y eliminar (DELETE).

---

## Actividad 01 — Consumo de API (GET) y filtro de búsqueda

### ¿Cuál es la función del `@Published`?

`@Published` es un *property wrapper* que se usa dentro de una clase `ObservableObject`.
Marca una propiedad como "observable": cada vez que su valor cambia, se emite
automáticamente una notificación a las vistas SwiftUI que están suscritas al ViewModel.
Esto provoca que la interfaz se **vuelva a dibujar (refresque) sola**, sin que tengamos que
actualizarla manualmente. En este laboratorio, cuando `users` o `searchText` cambian, la
lista de la pantalla se actualiza al instante.

### Explique brevemente qué se realiza dentro de `filteredUsers`

`filteredUsers` es una *computed property* (propiedad calculada) que devuelve la lista de
usuarios a mostrar según el texto de búsqueda:

- Si `searchText` está vacío (`searchText.isEmpty`), devuelve **todos** los usuarios.
- Si hay texto, usa `.filter { ... }` para devolver únicamente los usuarios cuyo `name`
  **contiene** el texto buscado. La comparación se hace con `.lowercased()` en ambos lados
  (nombre y búsqueda) para que **no distinga entre mayúsculas y minúsculas**.

Así, la lista que ve el usuario se actualiza dinámicamente mientras escribe en el campo de
búsqueda.

---

## Actividad 02 — Métodos POST, PUT y DELETE

> Nota: en la Actividad 02 las peticiones se hacían con `URLSession.shared.dataTask`,
> que usa *closures* y `.resume()`. En la Actividad 03 ese mismo código se reescribió con
> `async/await`. Las preguntas siguientes se responden sobre la versión con `dataTask`.

### ¿Cuál es la finalidad de la función `resume()`?

Cuando se crea una tarea de red con `URLSession.shared.dataTask(...)`, esta nace en estado
**suspendido (pausado)**, es decir, **no se ejecuta sola**. La función `.resume()` es la que
**inicia/arranca** la petición a la red. Si se olvida llamar a `resume()`, la petición nunca
se envía y nunca se reciben datos.

### ¿Qué función cumple `DispatchQueue`?

`DispatchQueue` administra en qué **hilo (thread)** se ejecuta un bloque de código.
La respuesta de la API llega en un **hilo secundario (en segundo plano)**, pero en iOS
**toda actualización de la interfaz debe hacerse en el hilo principal**. Por eso usamos
`DispatchQueue.main.async { ... }`: para volver al **hilo principal** y asignar ahí los datos
a las propiedades `@Published` (por ejemplo `self.users = decodedUsers`), evitando errores y
asegurando que la vista se refresque correctamente.

### ¿Qué función cumple la clase `JSONDecoder()`?

`JSONDecoder()` se encarga de **decodificar (convertir)** los datos JSON crudos que llegan de
la API (`Data`) en objetos Swift de nuestro modelo. Como `User` cumple el protocolo
`Codable`, con `try JSONDecoder().decode([User].self, from: data)` el JSON se transforma
automáticamente en un arreglo `[User]` listo para usar en la app. Es el proceso inverso a
`JSONEncoder()`, que convierte un objeto Swift en JSON para enviarlo (POST/PUT).

### Explicar las siguientes acciones

**`@State private var editingUser: User? = nil`**
Declara una variable de estado local de la vista que guarda el usuario que se está editando.
Es opcional (`User?`): si vale `nil` significa que **no** se está editando (modo "Nuevo
usuario"); si contiene un usuario, la vista entra en modo "Editar". Al ser `@State`, cualquier
cambio en su valor hace que SwiftUI vuelva a dibujar la vista.

**`@StateObject private var viewModel = UserViewModel()`**
Crea y mantiene **una sola instancia** del `UserViewModel` durante todo el ciclo de vida de la
vista. `@StateObject` es el propietario del objeto observable: la vista se suscribe a sus
propiedades `@Published` y se actualiza cuando estas cambian. Se usa `@StateObject` (y no
`@ObservedObject`) porque esta vista es la que **crea** el ViewModel.

**`.swipeActions`**
Modificador que agrega **acciones al deslizar** una fila de la `List` (gesto de *swipe*).
En este laboratorio se usan para mostrar los botones **Eliminar** (rojo, `.destructive`) y
**Editar** (azul) al deslizar cada usuario.

**`.sheet(isPresented: $showingForm)`**
Presenta una vista **modal** (que sube desde abajo) cuando la variable enlazada
`showingForm` se vuelve `true`. Aquí se usa para mostrar el `UserFormView`, ya sea para
agregar un nuevo usuario o para editar uno existente. Al cerrar el modal, `showingForm`
vuelve a `false` automáticamente.

---

## Actividad 03 — `URLSession` con `async/await`

### Diferencia entre `URLSession.shared.data` y `URLSession.shared.dataTask`

| `URLSession.shared.dataTask` | `URLSession.shared.data` |
|------------------------------|--------------------------|
| Es **asíncrono basado en closures** (callbacks). | Es **asíncrono basado en `async/await`**. |
| Hay que llamar a `.resume()` para iniciar la petición. | Se inicia sola al usar `await`; no necesita `.resume()`. |
| El resultado llega dentro de un *completion handler* y normalmente hay que volver al hilo principal con `DispatchQueue.main.async`. | El resultado se devuelve directamente como una tupla `(data, response)`; el código se lee de forma secuencial, de arriba hacia abajo. |
| Manejo de errores con `if let error` / opcionales. | Manejo de errores con `do / try / catch`. |

En resumen, `data(from:)` / `data(for:)` produce un código **más limpio, lineal y fácil de
leer**, evitando el "anidamiento" de closures del `dataTask`.

### ¿Para qué sirve la palabra reservada `await`?

`await` se usa para **esperar el resultado de una operación asíncrona** sin bloquear el hilo.
Marca un "punto de suspensión": el programa **pausa** esa función hasta que la tarea (por
ejemplo, la descarga de la red) termine, y mientras tanto el sistema puede seguir atendiendo
otras tareas. Solo puede usarse dentro de funciones marcadas con `async` o dentro de un
`Task`.

### ¿Para qué sirve la estructura `Task`?

`Task` crea un **contexto de ejecución asíncrono** que permite llamar a funciones `async`
(que usan `await`) desde un lugar que **no es asíncrono**, como los closures de la interfaz
(`.onAppear`, el botón de los `swipeActions`, etc.). En este laboratorio se usa, por ejemplo,
`Task { await viewModel.fetchUsers() }` dentro de `.onAppear` para lanzar la carga de
usuarios al aparecer la pantalla.

---

## Conclusiones

- El patrón **MVVM** separa claramente las responsabilidades: el **Model** (`User`) define los
  datos, el **ViewModel** (`UserViewModel`) concentra la lógica de red y el consumo de la API,
  y la **View** (`ContentView`, `UserFormView`) solo se encarga de mostrar la información. Esto
  hace el código más ordenado, reutilizable y fácil de mantener.
- El uso de `@Published`, `@StateObject` y `@State` permite una interfaz **reactiva**: la
  pantalla se actualiza automáticamente cuando cambian los datos, sin tener que refrescarla
  manualmente.
- Migrar de `dataTask` con closures a `async/await` simplifica notablemente el consumo de APIs:
  el código queda **secuencial y legible**, el manejo de errores se centraliza con
  `do/try/catch` y `MainActor.run` reemplaza a `DispatchQueue.main.async` para volver al hilo
  principal de forma segura.
