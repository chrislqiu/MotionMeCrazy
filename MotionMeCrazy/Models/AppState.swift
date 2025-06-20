//
//  AppState.swift
//  MotionMeCrazy
//
//  Created by Ethan Donahue on 3/5/25.
//

import Combine

class AppState: ObservableObject {
    @Published var offlineMode: Bool = false
    @Published var loading: Bool = true
    @Published var darkMode: Bool = false
    @Published var currentLanguage: String = "EN"
    
    var localizedStrings: [String: [String: String]] = [
        "EN": [
               "Play Offline": "Play Offline",
               "Enter your username": "Enter your username",
               "Copied to clipboard!": "Copied to clipboard!",
               "Start": "Start",
               "Select Your Profile Picture": "Select Your Profile Picture",
               "Settings": "Settings",
               "Audio Level": "Audio Level",
               "Light mode": "Light mode",
               "Dark mode": "Dark mode",
               "Change Theme": "Change Theme",
               "Change Language": "Change Language",
               "Theme Options:": "Theme Options:",
               "Default": "Default",
               "Most Popular": "Most Popular",
               "Least Popular": "Least Popular",
               "Revert to Default": "Revert to Default",
               "Personal": "Personal",
               "Everyone": "Everyone",
               "Game Center": "Game Center",
               "Leaderboard": "Leaderboard",
               "Hole In Wall": "Hole In Wall",
               "Game 2": "Game 2",
               "Game 2 Coming Soon!": "Game 2 Coming Soon!",
               "Level %d/%d Completed!": "Level %d/%d Completed!",
               "Score: %d": "Score: %d",
               "Remaining Lives: %d": "Remaining Lives: %d",
               "Next Level": "Next Level",
               "Quit Game": "Quit Game",
               "Are you sure you want to quit?": "Are you sure you want to quit?",
               "No": "No",
               "Yes": "Yes",
               "Level %d/%d Failed!": "Level %d/%d Failed!",
               "Remaining Health: %d": "Remaining Health: %d",
               "Retry Level": "Retry Level",
               "Friends": "Friends",
               "All": "All",
               "Pending": "Pending",
               "Sent": "Sent",
               "This page is not available in offline mode": "This page is not available in offline mode",
               "Search...": "Search...",
               "Search": "Search",
               "Add": "Add",
               "Friend request has been sent": "Friend request has been sent",
               "Friend request already exists and is pending": "Friend request already exists and is pending",
               "Score": "Score",
               "Health": "Health",
               "Progress": "Progress",
               "Game Paused": "Game Paused",
               "Game Settings": "Game Settings",
               "Resume": "Resume",
               "Public": "Public",
               "Public Leaderboard": "Public Leaderboard",
               "Friends Leaderboard": "Friends Leaderboard",
               "My Leagues": "My Leagues",
               "You are not in any leagues": "You are not in any leagues",
               "%@ (Code: %@)": "%@ (Code: %@)",
               "Other Leagues": "Other Leagues",
               "No other leagues available": "No other leagues available",
               "Create League": "Create League",
               "Join League": "Join League",
               "Enter League Code": "Enter League Code",
               "Type here...": "Type here...",
               "Submit": "Submit",
               "Cancel": "Cancel",
               "Close": "Close",
               "Create Your League": "Create Your League",
               "Enter league name": "Enter league name",
               "Pending Requests": "Pending Requests",
               "ID: %d": "ID: %d",
               "Accept": "Accept",
               "Decline": "Decline",
               "Profile": "Profile",
               "Edit": "Edit",
               "User ID: %d": "User ID: %d",
               "Edit Username": "Edit Username",
               "Enter a new username": "Enter a new username",
               "Please enter a new username": "Please enter a new username",
               "Badges": "Badges",
               "Stats": "Stats",
               "Sent Requests": "Sent Requests",
               "Statistics": "Statistics",
               "Total Time Played: %@": "Total Time Played: %@",
               "Past Day": "Past Day",
               "Past Week": "Past Week",
               "Past Month": "Past Month",
               "High Scores From The: %@": "High Scores From The: %@",
               "High Score": "High Score",
               "Longest Session": "Longest Session",
               "View All": "View All",
               "Share": "Share",
               "Clear": "Clear",
               "Spanish":  "Spanish",
               "English": "English",
               "Language Options:": "Language Options:",
               "No users found": "No users found",
               "Played %d times" : "Played %d times",
               "You played this %d times": "You played this %d times",
               "Music":"Music",
               "Difficulty":"Difficulty",
               "Daily Missions": "Daily Missions",
               "Skip": "Skip",
               "Back": "Back",
               "Next": "Next",
               "This is your score. It increases as you progress in the game!" : "This is your score. It increases as you progress in the game!",
               "This is your health. If it reaches zero, you lose!" : "This is your health. If it reaches zero, you lose!",
               "This is your progress. It shows what level you’re on." : "This is your progress. It shows what level you’re on.",
               "Tap the pause button to pause the game." : "Tap the pause button to pause the game.",
               "That's the tutorial! Press play to start the game!" : "That's the tutorial! Press play to start the game!",
               "Welcome to the game!" :  "Welcome to the game!",
               "Session Time: %d h": "Session Time: %d h",
               "Earn 500 points in hard mode": "Earn 500 points in hard mode",
                "Dodge 10 obstacles": "Dodge 10 obstacles",
                "Play 5 levels": "Play 5 levels",
               "Sound Effects":"Sound Effects",
               "Change Mode":"Change Mode",
               "Each ❌ shows where you 'hit' the wall. The total number of hits you have per wall will determine if you get 50, 75, or 100 points for that wall.": "Each ❌ shows where you 'hit' the wall. The total number of hits you have per wall will determine if you get 50, 75, or 100 points for that wall.",
                  "Every time you clear a wall (having 0 hits or ❌), you get +100 points": "Every time you clear a wall (having 0 hits or ❌), you get +100 points",
                  "For every level where you go through each wall with 0 hits in total, you get a level bonus of 100 points!": "For every level where you go through each wall with 0 hits in total, you get a level bonus of 100 points!",
               "Scoring":"Scoring",
               "Modes": "Modes",
               "Themes":"Themes",
               "Your Plays: %d": "Your Plays: %d",
               "Plays: %d": "Plays: %d",
               "Enter your name": "Enter your name",
                       "Name": "Name",
                       "Create": "Create",
                       "Enter join code": "Enter join code",
                       "Code": "Code",
                       "Join": "Join",
               "Normal": "Normal",
                       "Hard": "Hard",
                       "Easy": "Easy",
                       "Random": "Random",
                       "Accessibility": "Accessibility",
                       "Game Mode Options:": "Game Mode Options:"
               
           ],
        "ES": [
            "Play Offline": "Jugar sin conexión",
            "Enter your username": "Introduce tu nombre de usuario",
            "Copied to clipboard!": "¡Copiado al portapapeles!",
            "Start": "Iniciar",
            "Select Your Profile Picture": "Selecciona tu foto de perfil",
            "Settings": "Configuración",
            "Audio Level": "Nivel de audio",
            "Light mode": "Modo claro",
            "Dark mode": "Modo oscuro",
            "Change Theme": "Cambiar tema",
            "Change Language": "Cambiar idioma",
            "Theme Options:": "Opciones de tema:",
            "Default": "Predeterminado",
            "Most Popular": "Más popular",
            "Least Popular": "Menos popular",
            "Revert to Default": "Restablecer a predeterminado",
            "Personal": "Personal",
            "Everyone": "Todos",
            "Game Center": "Centro de juegos",
            "Leaderboard": "Clasificación",
            "Hole In Wall": "Hueco en la pared",
            "Game 2": "Juego 2",
            "Game 2 Coming Soon!": "¡Juego 2 muy pronto!",
            "Level %d/%d Completed!": "¡Nivel %d/%d completado!",
            "Score: %d": "Puntuación: %d",
            "Remaining Lives: %d": "Vidas restantes: %d",
            "Next Level": "Siguiente nivel",
            "Quit Game": "Salir del juego",
            "Are you sure you want to quit?": "¿Estás seguro de que quieres salir?",
            "No": "No",
            "Yes": "Sí",
            "Level %d/%d Failed!": "¡Nivel %d/%d fallido!",
            "Remaining Health: %d": "Salud restante: %d",
            "Retry Level": "Reintentar nivel",
            "Friends": "Amigos",
            "All": "Todos",
            "Pending": "Pendientes",
            "Sent": "Enviados",
            "This page is not available in offline mode": "Esta página no está disponible sin conexión",
            "Search...": "Buscar...",
            "Search": "Buscar",
            "Add": "Agregar",
            "Friend request has been sent": "Solicitud de amistad enviada",
            "Friend request already exists and is pending": "La solicitud de amistad ya existe y está pendiente",
            "Score": "Puntuación",
            "Health": "Salud",
            "Progress": "Progreso",
            "Game Paused": "Juego en pausa",
            "Game Settings": "Configuración del juego",
            "Resume": "Reanudar",
            "Public": "Público",
            "Public Leaderboard": "Clasificación pública",
            "Friends Leaderboard": "Clasificación de amigos",
            "My Leagues": "Mis ligas",
            "You are not in any leagues": "No estás en ninguna liga",
            "%@ (Code: %@)": "%@ (Código: %@)",
            "Other Leagues": "Otras ligas",
            "No other leagues available": "No hay otras ligas disponibles",
            "Create League": "Crear liga",
            "Join League": "Unirse a la liga",
            "Enter League Code": "Ingresa el código de la liga",
            "Type here...": "Escribe aquí...",
            "Submit": "Enviar",
            "Cancel": "Cancelar",
            "Close": "Cerrar",
            "Create Your League": "Crea tu liga",
            "Enter league name": "Ingresa el nombre de la liga",
            "Pending Requests": "Solicitudes pendientes",
            "Sent Requests": "Solicitudes enviadas",
            "ID: %d": "ID: %d",
            "Accept": "Aceptar",
            "Decline": "Rechazar",
            "Profile": "Perfil",
            "Edit": "Editar",
            "User ID: %d": "ID de usuario: %d",
            "Edit Username": "Editar nombre de usuario",
            "Enter a new username": "Ingresa un nuevo nombre de usuario",
            "Please enter a new username": "Por favor, ingresa un nuevo nombre de usuario",
            "Badges": "Insignias",
            "Stats": "Estadísticas",
            "Statistics": "Estadísticas",
            "Total Time Played: %@": "Tiempo total jugado: %@",
            "Past Day": "Último día",
            "Past Week": "Última semana",
            "Past Month": "Último mes",
            "High Scores From The: %@": "Puntuaciones más altas del: %@",
            "High Score": "Puntuación más alta",
            "Longest Session": "Sesión más larga",
            "View All": "Ver todo",
            "Share": "Compartir",
            "Clear": "Borrar",
            "Spanish": "Español",
            "English": "Inglés",
            "Language Options:": "Opciones de idioma:",
            "No users found": "No se encontraron usuarios",
            "Played %d times":"Jugado %d veces",
            "You played this %d times": "Jugaste esto %d veces",
            "Music": "Música",
            "Difficulty":"Dificultad",
            "Daily Missions": "Misiónes Diarias",
            "Skip": "Saltar",
            "Back": "Atras",
            "Next": "Próximo",
            "This is your score. It increases as you progress in the game!" : "Esta es tu puntuación. ¡Aumenta a medida que avanzas en el juego!",
            "This is your health. If it reaches zero, you lose!" : "Esta es tu salud. ¡Si llega a cero, pierdes!",
            "This is your progress. It shows what level you’re on." : "Este es tu progreso. Muestra en qué nivel estás.",
            "Tap the pause button to pause the game." : "Toca el botón de pausa para pausar el juego.",
            "That's the tutorial! Press play to start the game!" : "¡Ese fue el tutorial! Presiona jugar para comenzar el juego.",
            "Welcome to the game!" : "¡Bienvenido al juego!",
            "Session Time: %d h" : "Tiempo de sesión: %d h",
            "Earn 500 points in hard mode": "Consigue 500 puntos en modo difícil",
            "Dodge 10 obstacles": "Esquiva 10 obstáculos",
            "Play 5 levels": "Juega 5 niveles",
            "Sound Effects": "Efectos de sonido",
            "Change Mode": "Cambiar modo",
            "Each ❌ shows where you 'hit' the wall. The total number of hits you have per wall will determine if you get 50, 75, or 100 points for that wall.": "Cada ❌ muestra dónde chocaste con el muro. El número total de golpes por muro determinará si obtienes 50, 75 o 100 puntos por ese muro.",
            "Every time you clear a wall (having 0 hits or ❌), you get +100 points": "Cada vez que pasas un muro sin ❌ (sin golpes), obtienes +100 puntos",
            "For every level where you go through each wall with 0 hits in total, you get a level bonus of 100 points!": "Por cada nivel en el que pasas todos los muros sin ningún ❌, obtienes un bono de nivel de 100 puntos.",
            "Scoring": "Puntuación",
            "Modes": "Modos",
            "Themes": "Temas",
            "Plays: %d": "Partidas: %d",
            "Enter your name": "Ingresa tu nombre",
                    "Name": "Nombre",
                    "Create": "Crear",
                    "Enter join code": "Ingresa el código",
                    "Code": "Código",
                    "Join": "Unirse",
            "Create Game": "Crear Partida",
            "Join Game": "Unirse a la partida",
            "Normal": "Normal",
                    "Hard": "Difícil",
                    "Easy": "Fácil",
                    "Random": "Aleatorio",
                    "Accessibility": "Accesibilidad",
                    "Game Mode Options:": "Opciones de modo de juego:"
            
        ]
    ]


    func localized(_ key: String) -> String {
        return localizedStrings[currentLanguage]?[key] ?? key
    }
}
