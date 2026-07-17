class Song {
  final String title;
  final String text;
  final String tonalidad;
  final int tiempo;
  final int? status;
  final String? multitrackLink; // Nuevo campo para el enlace de multitrack
  final String? youtubeLink; // Nuevo campo para el enlace de YouTube
  final List<String>? guitarLink; // Enlace para guitarra (opcional)
  final List<String>? pianoLink; // Enlace para piano (opcional)
  final List<String>? bassLink; // Enlace para bajo (opcional)
  final List<String>? drumsLink; // Enlace para batería (opcional)
  final List<String>? voicesLinks; // Enlace para voces (opcional)
  final int? instrument;
  final String? textPlano; // Versión simplificada para el buscador (Firestore)
  final String? categoria; // "adoracion" o "alabanza" (Firestore)

  Song({
    required this.title,
    required this.text,
    required this.tonalidad,
    required this.tiempo,
    this.status,
    this.instrument,
    this.multitrackLink,
    this.youtubeLink,
    this.guitarLink,
    this.pianoLink,
    this.bassLink,
    this.drumsLink,
    this.voicesLinks,
    this.textPlano,
    this.categoria,
  });

  /// Construye una Song a partir de un documento de Firestore.
  factory Song.fromMap(Map<String, dynamic> map) {
    List<String>? asStringList(dynamic value) {
      if (value == null) return null;
      return List<String>.from(value as List);
    }

    return Song(
      title: map['title'] as String,
      text: map['text'] as String,
      tonalidad: map['tonalidad'] as String? ?? '',
      tiempo: (map['tiempo'] as num?)?.toInt() ?? 0,
      status: (map['status'] as num?)?.toInt(),
      instrument: (map['instrument'] as num?)?.toInt(),
      multitrackLink: map['multitrackLink'] as String?,
      youtubeLink: map['youtubeLink'] as String?,
      guitarLink: asStringList(map['guitarLink']),
      pianoLink: asStringList(map['pianoLink']),
      bassLink: asStringList(map['bassLink']),
      drumsLink: asStringList(map['drumsLink']),
      voicesLinks: asStringList(map['voicesLinks']),
      textPlano: map['textPlano'] as String?,
      categoria: map['categoria'] as String?,
    );
  }

  /// Convierte esta Song a un Map serializable (para cache local en JSON).
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
      'tonalidad': tonalidad,
      'tiempo': tiempo,
      'status': status,
      'instrument': instrument,
      'multitrackLink': multitrackLink,
      'youtubeLink': youtubeLink,
      'guitarLink': guitarLink,
      'pianoLink': pianoLink,
      'bassLink': bassLink,
      'drumsLink': drumsLink,
      'voicesLinks': voicesLinks,
      'textPlano': textPlano,
      'categoria': categoria,
    };
  }
}
 /*
  Song(
    title: "",
    text: """

""",
    tonalidad: "",
    tiempo: ,
     
    multitrackLink: "",  
    youtubeLink: "",
    instrument: 1,
    voicesLinks: [
      "",
    ],
    guitarLink: [
      "",
    ],
    pianoLink: [
      "",
    ],
    bassLink: [
      "",
    ],
    drumsLink: [
      "",
    ] 
  ),
  */
final List<Song> cancionesCompletas = [
  Song(
    title: "ALELUYA",
    text: """
CANCIÓN: Aleluya - MCLV
TONALIDAD: Em
TIEMPO: 65bpm

INTRO: // Em D //
Em
Hermoso eres Dios 
               D
tan lleno de amor
Em                       D
tu fidelidad me acompañará
Em
Eres tú mi luz
             D
en mi oscuridad
Em
mi corazón te anhela 
          D
cada día más

CORO:
Em      C
Aleluya aleluya 
D                      Em
santo santo santo eres tú
Em       C
Aleluya Aleluya 
D                        Em
digno eres Dios de adoración
""",
    tonalidad: "Em",
    tiempo: 65,
    instrument: 0,
  ),
  Song(
    title: "AMAMOS TU PRESENCIA",
    text: """
CANCIÓN: Amamos tu presencia 
MSM ft. Marcos Brunet
TONALIDAD: E
TIEMPO: 70bpm

INTRO: B - C#m - E - A  x 4

VERSO:
    E                      
Encuentro  sanidad,  
    C#m
encuentro  libertad
          B       A
En tu presencia    
    E                      
Encuentro hoy perdón
    C#m
Encuentro salvación 
          B       A
En tu presencia    

PRE-CORO:
   B          C#m - E     A
//Correremos  ha---cia    ti
    B           C#m - E      A
El Cielo hoy esta     a-----quí//

CORO:
  E          C#m          B
Amamos tu presencia  oh Dios
  A                       E
Amamos tu presencia  oh Dios
  E          C#m          B
Amamos tu presencia  oh Dios
  A          C#m         F#m
Amamos tu presencia  oh Dios

SOLO:
B - C#m - E - A  x 4
""",
    tonalidad: "E",
    tiempo: 70,
      
    instrument: 1,
    multitrackLink: "https://youtu.be/J5Xe7o5QYng?si=slUbXPdCLTEauUA_",  
    youtubeLink: "https://youtu.be/Qd2gtLAy22w?si=ci2fsXvuy4LRN6gw", 
    voicesLinks: [
      "https://youtu.be/rSbMx8SpiqA",
      "https://youtu.be/mt2P84rJmbo",
    ],
    guitarLink: [
      "https://youtu.be/WAIpqorbFfk?si=6XEeGU63U0nYMkJj",
      "https://youtu.be/zYggaExIayo?si=_J2Qz4QG1n_R-pcd",
      "https://youtu.be/bjNZU_Zxucg?si=sFrFhqGdmhpGxP6s",
      "https://youtu.be/CgwE-CSLYzM",
      "https://youtu.be/rBV-RaIpS5A",
      "https://youtu.be/DMM_d5y9CB0",

    ],
    pianoLink: [
      "https://youtu.be/29iPPk2C2hs",
      "https://youtu.be/1VwLnhqQSwY",
      "https://youtu.be/lIW6StEehiA",
      "https://youtu.be/LAbYPEczx60",
    ],
    bassLink: [
      "https://youtu.be/Wf9mlbP1K50",
      "https://youtu.be/VaceWyS1CY4",
    ],
    drumsLink: [
      "https://youtu.be/zRt398g6D_0",
      "https://youtu.be/58_uouC3VMY",
      "https://youtu.be/Rz3HxBKiosI",
      "https://youtu.be/TRti1mvq-eg",
    ]
      ),
  Song(
    title: "CREO EN TI",
    text: """
CANCIÓN: Creo en ti - Julio Melgar
TONALIDAD: Bm
TIEMPO: 70bpm
        
INTRO: D - G ... G - A / D - G .... A
Bm                        G
Quiero levantar a ti mis Manos
      D                  A
Maravilloso Jesús, Milagroso señor
Bm                         G
Llena este lugar de tu presencia
          D                                                      
Has descender tu poder, 
                  A
a los que estamos aquí

PRE-CORO:
       Bm     A   G
Creo en ti... Je-sús
            Bm     A  G           
De lo que harás... en mi
    D          A
en mi...... en mi

CORO:
       Bm
Recibe toda la gloria
        G
Recibe toda la honra
    D             A
Precioso hijo de Dios
        
*Guitarra*: 
// Bm - G - D - A //
""",
    tonalidad: "Bm",
    tiempo: 70,
     
    multitrackLink: "https://youtu.be/5_t0z6s9uNU",  
    youtubeLink: "https://youtu.be/xJ_ZZkM5fGY?si=p7NGSVLIpwyrvoww", 
    instrument: 1,
     voicesLinks: [
      "https://youtu.be/lhNpPyWVRec",
    ],
    guitarLink: [
      "https://youtu.be/Xcr7ihpuSW8",
      "https://youtu.be/mKP3-SPc9CM",
      "https://youtu.be/9UfuJ9z6hp0?si=w7B3zCucZf2E7fJm",
      "https://youtu.be/soJvfgw6AVI",
    ],
    pianoLink: [
      "https://youtu.be/s1pngEHXbe8",
      "https://youtu.be/cRK6ladzBIo",
    ],
    bassLink: [
      "https://youtu.be/Inq1pFjCo-w",
    ],
    drumsLink: [
      "https://youtu.be/K4UftX-cwbA",
      "https://youtu.be/vOyfUnQNA-s",
      "https://youtu.be/kRzZfyEi3aI",
      "https://youtu.be/HU31Bq-x4Fk",
    ]
  ),
  Song(
    title: "DE GLORIA EN GLORIA",
    text: """
CANCIÓN: De gloria en gloria - Marcos Witt
TONALIDAD: D
TIEMPO: 58bpm

INTRO: D - A - Bm - F#m - G - A - D

     D         A        Bm   C
De gloria en gloria te veo
        G        D
Cuanto más te conozco
G                   A      A7
Quiero saber más de ti
    D          A       Bm    C
Mi Dios cual buen alfarero
    G              D
Quebrántame, transfórmame
    G           A       D   D7
Moldéame a tu imagen señor

CORO:
    G      A      F#m  Bm
// Quiero ser más como tú
G       A   F#m  Bm
Ver la vida como tú
G    A            F#m Bm
Saturarme de tu espíritu
   G           A         D  D7
y reflejar al mundo tu amor //
""",
    tonalidad: "D",
    tiempo: 58,
     
    multitrackLink: "https://youtu.be/U6Y9echh0no",  
    youtubeLink: "https://youtu.be/y_678O4S6l8?si=Wl8Yg4okgBrrKnFe", 
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/qSpLL1daOrE"
    ],
    guitarLink: [
      "https://youtu.be/6eY4GFzz_OI",
      "https://youtu.be/rhzxMaRUxXY",
      "https://youtu.be/CfNCeG41kT8",
      "https://youtu.be/wRd3n4M7_C0",
    ],
    pianoLink: [
      "https://youtu.be/cFnokLk8k0k",
      "https://youtu.be/TtgoPuK1J7g",
      "https://youtu.be/1mELNIwcGQA",
      "https://youtu.be/R95JF8NpGj8",
    ],
    bassLink: [
      "https://youtu.be/CcjxS3YJrQo",
      "https://youtu.be/ll0O8rx86jY",
      "https://youtu.be/jiwGv9kjDdA",
    ],
    
  ),
  Song(
    title: "DIOS DE LO IMPOSIBLE",
    text: """
CANCIÓN: Dios de lo imposible - Marco Barrientos 
Ft. David Reyes & Christine D'Clario
TONALIDAD: Am (original LA#m)
TIEMPO: 70bpm

INTRO: Am  - F  - C  - G 

VERSO 1
     Am                   F 
Jesucristo, reinas con poder
     C                G 
Soberano, victorioso Rey
       Am              F 
Ni la muerte pudo detener
      C           G 
Tu poder para vencer

CORO:
C 
Dios de lo imposible
G 
Te     adoramos
C 
Eres invencible
G 
Soberano
F                 G    Am - G 
Tuya es toda la gloria
F                  G 
Tuyo es todo el honor

SOLO:
A  - F  - C - G  (2x)
*Nuevamente repite el coro*
""",
    tonalidad: "Am (original LA#m)",
    tiempo: 70,     
     
    multitrackLink: "https://youtu.be/mxdx-7ZmGY8",  
    youtubeLink: "https://youtu.be/6NK71dQEq98", 
    instrument: 1,
    guitarLink: [
      "https://youtu.be/7fdIBnHrz_Q",
      "https://youtu.be/rdbVFhIsfK0",
      "https://youtu.be/eOflE76z158",
      "https://youtu.be/f-VTfkOCoTc",
    ],
    pianoLink: [
      "https://youtu.be/TaJM26U3RQw",
      "https://youtu.be/aXQFoUdXf6s",
    ],
    bassLink: [
      "https://youtu.be/1BozeTh9Hys",
      "https://youtu.be/tWMyJkzVyQs",
    ],
    drumsLink: [
      "https://youtu.be/aBZlKhxqZNc",
      "https://youtu.be/fVCb-xIYnsM",
      "https://youtu.be/H4pwrPt7-A8",
      "https://youtu.be/e4nuY1A1o4Q",
    ]
  ),  
  Song(
    title: "DIOS ESTÁ",
    text: """
CANCIÓN: Dios está aquí - Himno
TONALIDAD: D
TIEMPO: 65bpm

  D     A    D          
Dios está aquí 
      G                  A      D
tan cierto como el aire que respiro
      G                  A  
tan cierto como en la mañana 
    F#m Bm
se levanta 
      G                A                
tan cierto como yo te hablo 
             D
y me puedes oír.

*Se repite las notas solo cambia la palabra 
"Dios" por "Espíritu* y "Cristo"


CANCIÓN: El Espíritu de Dios - Himno
TONALIDAD: D
TIEMPO: 65bpm

        D                A    
//El Espíritu de Dios está 
           D
en este lugar
      D                 G              
El Espíritu de Dios se mueve 
           A
en este lugar
        D            G
Esta aquí para consolar
        D           G
Esta aquí para liberar
        D
Esta aquí para guiar
      A                    D    D7
El Espíritu de Dios esta aquí//

CORO
              G A             D
// Muévete en mi, muévete en mi
         G              A
Toma mi mente y mi corazón
         F#m          Bm
Llena mi vida de tu amor
           G           A               
Muévete en mi, Dios Espíritu,
            D
muévete en mi//
""",
    tonalidad: "D",
    tiempo: 65,
    status: 1,
    instrument: 0,
  ),
  Song(
    title: "EL PODER DE TU GLORIA",
    text: """
CANCIÓN: El poder de tu gloria - 
Paul Wilbur
TONALIDAD: Dm
TIEMPO: 67bpm

INTRO: Dm ..... Bb - C - Dm

    Dm
//Espíritu de santo Dios
Dm
ven a este presente hoy
  Bb           C           Dm
revélanos la gloria de tu reino//

CORO:
       Bb         C
Con poder de tu gloria
Dm
cúbrenos...
        Bb      C    Dm
vida nueva fluirá en ti
       Bb        C
la verdad de tu reino
 Dm
muéstranos.....

PUENTE:
          Bb         C
con el poder de tu gloria
          Bb         C     Dm
con el poder de tu gloria cúbrenos
""",
    tonalidad: "Dm",
    tiempo: 67,
     
    youtubeLink: "https://youtu.be/_BFIBhu8lCw?si=cc2swSvkiX8p0Y2Q", 
    instrument: 0,
  ),
  Song(
    title: "ESCUCHARTE HABLAR",
    text: """
CANCIÓN: Escucharte hablar - Marcos Witt
TONALIDAD: G
TIEMPO: 143bpm

INTRO: // G - D - C - D //

G                    D
 Quiero escuchar tu dulce voz
     C                      D
rompiendo el silecio en mi ser
G                   D
sé que me haría estremecer
      C             D 
me haría llorar o reír
      C     Am         D
y caería rendido ante ti

CORO: 
   G           D
Y no podría estar ante ti 
      C             
escuchándote hablar 
        Am          D
sin llorar como un niño
  G           D
y pasaría el tiempo así
        C
sin querer nada más
     Am            D        G
nada más que escucharte hablar
*vuelve al intro*
""",
    tonalidad: "G",
    tiempo: 143,    
     
    multitrackLink: "https://youtu.be/ejZjs_bqG0s",  
    youtubeLink: "https://youtu.be/N7-_ehqAH9o?si=Hh8iB2tlEhp6tLyL", 
    instrument: 1,
    voicesLinks: [
      "https://www.youtube.com/watch?v=YXqGe1IMW2c&ab_channel=DayenneOliveiraoficial",
    ],
    guitarLink: [
      "https://youtu.be/FEvYj_AuioM",
      "https://youtu.be/Kr46M3gdhng",
      "https://youtu.be/c4yvnzHX38A",
      "https://youtu.be/HNDbDEiyDsQ",
    ],
    pianoLink: [
      "https://youtu.be/lTBpBXyfiEA",
      "https://youtu.be/tU_SRdmSSL0",
      "https://youtu.be/v9RSNcHs0rM",
      "https://youtu.be/6Cwgn3GDenM",
    ],
    bassLink: [
      "https://youtu.be/ibSQq_k25WE",
      "https://youtu.be/lxEhd1MxDuw",
    ],
    drumsLink: [
      "https://youtu.be/rHZdGCFF79Y",
      "https://youtu.be/aW3POMzcgho",
      "https://youtu.be/2bm9rWIFhQg",
    ]
  ),
  Song(
    title: "ESTÁ CAYENDO",
    text: """
CANCIÓN: Está cayendo - Jose Luis Reyes
TONALIDAD: G
TIEMPO: 130bpm

INTRO: // G Em C D // Am
G                Am
//Algo cayendo aquí
D                      G
  Es tan fuerte sobre mí
Em                 Am
  Mis manos levantaré
D                  G     C G
  Y su Gloria tocaré//

CORO
D         G                     D
  Está cayendo, su Gloria sobre mi
          Am                    G C
Sanando heridas, levantando al caído
                  D
Su Gloria está aquí//
                  G Em C D
Su Gloria está aquí *solo una vez*

FINAL
                  // Em D Am D // G
 ///Su Gloria está aquí///
""",
    tonalidad: "G",
    tiempo: 130,
     
    multitrackLink: "https://youtu.be/O78oByp1wjg",  
    youtubeLink: "https://youtu.be/8BTSEvTyztg?si=yIzwBD_4CWDU3JKX", 
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/XytqaHIofWg",
    ],
    guitarLink: [
      "https://youtu.be/-oIbWngpLhc",
      "https://youtu.be/cmoHmYfr0uY",
      "https://youtu.be/ICjysQbyrn4",
    ],
    pianoLink: [
      "https://youtu.be/Uu9h1j2qpfA",
      "https://youtu.be/UCMe0bzeNeA",
      "https://youtu.be/L7bhilvMPv0",
      "https://youtu.be/Hart0DNvkw8",
    ],
    bassLink: [
      "https://youtu.be/lnYIl5k765k",
      "https://youtu.be/9jJNQPUWiBI",
    ],
    drumsLink: [
      "https://youtu.be/SPbHrrUNfY0",
      "https://youtu.be/mmPx4K421Ek",
      "https://youtu.be/-EqABKyif_M",
    ]
  ),
  Song(
    title: "FAZ CHOVER",
    text: """
CANCIÓN: Has llover - Fernandinho
TONALIDAD: D
TIEMPO: 73bpm

INTRO: // Bm - G - D - A // G

    D                  A       Bm
//Así como el ciervo anhela el agua
G                     D        A
Como tierra seca necesita la lluvia
    G    A        D      G
Mi corazón tiene sed de ti
     D        A
mi Dios y mi rey//

CORO:
        Bm - G     D     A
Haz llover     señor Jesús
         Bm       G       A
Derrama lluvia en este lugar
           Bm - G       D     A
Ven con tu rio,     señor Jesús
     Bm    G      A
Inundando mi corazón

*En la guitarra: Bm - G - D - A*

      C#m - A      E     B
Haz llover      señor Jesús
        C#m       A       B
Derrama lluvia en este lugar
           C#m - A    E     B
Ven con tu rio,    señor Jesús
    C#m    A      B
Inundando mi corazón
""",
    tonalidad: "D",
    tiempo: 73,
     
    youtubeLink: "https://youtu.be/oVyqYPPX1Ak", 
    instrument: 0,
  ),
  Song(
    title: "FUENTE DE VIDA",
    text: """
CANCIÓN: Fuente de vida - Marco Barrientos
TONALIDAD: Dm
TIEMPO: 76bpm

INTRO: // G/B - C/G - Bb //
   Dm                C
En Ti esta todo, de Ti fluye vida
     G/B                Bb
A Ti puedo correr, a Ti puedo clamar
     Dm                 C
Tus Brazos de aliento, son mi sustento
     G/B               Bb
Si Tu Estás conmigo, quien contra mi

PRE-CORO
     Dm          Bb
Vuelvo mis ojos, a la fuente
 F             C            Dm   Bb C
Donde esta la Vida Eterna, Jesucristo

CORO
Dm             Bb
Eres Salvador, Hijo de Dios,
 F                 
Sanas mis heridas, 
      C
me liberas con Tu Amor,
Dm              Bb
Eres Salvador, Hijo de Dios,
 F                       
Sanas mis heridas, 
      C
me liberas del temor,
""",
    tonalidad: "Dm",
    tiempo: 76,
     
    multitrackLink: "https://youtu.be/bQAscJcrhps",  
    youtubeLink: "https://youtu.be/OoiezzmZhHc", 
    instrument: 1,
    
    guitarLink: [
      "https://youtu.be/FDabnKK-1_s",
      "https://youtu.be/7TQta7OUwGw",
    ],
    pianoLink: [
      "https://youtu.be/2UDz4_l0D-Y",
      "https://youtu.be/8FN1LhZMf5U",
    ],
    drumsLink: [
      "https://youtu.be/2w7tULYvptc",
      "https://youtu.be/MMk_dNW0Xnk",
    ]
  ),
  Song(
    title: "GLORIA",
    text: """
CANCIÓN: Grande Eres Tu - Himno
TONALIDAD: D
TEMPO: 76 bpm
TIEMPO: 65bpm 

INTRO: // D F#m G A //
                  D         F#m7
//Queremos darte gloria, y alabanza
      G                       Em7      
levantamos nuestras manos, adorandote
A
señor//

CORO:
            D
grande eres tú
      A/C#         Bm7
grande tus milagros son
        F#m       G   G Em7
no hay otro como tú
       Em         A             
no hay otro como tú

FINAL:
       G    A     D
no hay otro como tú

CANCIÓN: Mereces la gloria - Himno
TONALIDAD: D
TEMPO: 55 bpm

INTRO: // D F#m G A //
                D           F#m  
De Dios es la gloria, y la honra
      G             
levantámos nuestras manos,
     Em        A
exaltándote señor//

CORO 
         D      A/C#        Bm
//altísimo, milagroso  salvador,
       F#m          G
no hay otro como  tú
       Em         A7
no hay otro como tú//

FINAL
       Em     A   D
no hay otro como tú
""",
    tonalidad: "D",
    tiempo: 76,
    instrument: 0,
     
    youtubeLink: "https://youtu.be/8ASm7Sqmlqc?si=Gf_pib8VAFCUDtpo", 
  ),
  Song(
    title: "GRACIAS",
    text: """
CANCIÓN: Gracias - Marcos Witt
TONALIDAD: F#m
TIEMPO: 60bpm

INTRO: // F#m - E //

VERSO 1:
         F#m
Me has tomado en tus brazos
          E
Y me has dado salvación
       F#m              
De tu amor has derramado 
           E
en mi corazón
      F#m
No sabré agradecerte
            E
Lo que has hecho por mí
      F#m                      E
Solo puedo darte ahora mi canción

CORO:
            A  E
Yo te doy gracias
Bm7       F#m7 E
Gracias Señor
  A           E     D   E 
Gracias mi Señor Jesús

  A  E           Bm       F#m    E 
Gracias, muchas gracias Señor

  A           E     D 
Gracias mi Señor Jesús

VERSO 2:
       F#m7
En la cruz diste tu vida
      E
Entregaste todo ahí
      F#m7               E
Vida eterna regalaste al morir
       F#m7
Por tu sangre tengo entrada
          E
Ante el trono Celestial
        F#m7                     E
Puedo entrar confiadamente ante ti
""",
    tonalidad: "D",
    tiempo: 60,
     
    multitrackLink: "https://youtu.be/ghpTOSUp7NM",  
    youtubeLink: "https://youtu.be/tBelHlj0440",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/5K1wXvtPwxY",
      "https://youtu.be/06cYf0qsY5M",
      "https://youtu.be/tgP0_Wp6-8c",
      "https://youtu.be/ljpcSxrEfy8",
      "https://youtu.be/kRspjW6M3-0",
    ],
    pianoLink: [
      "https://youtu.be/HkgPnfNqFMw",
      "https://youtu.be/IYhaatHieGs",
      "https://youtu.be/evkq6PVMsak",
    ],
    bassLink: [
      "https://youtu.be/Qn7gB4RJnPw",
      "https://youtu.be/jg6rObUKK6w",
    ],
    drumsLink: [
      "https://youtu.be/YeTGxNzI7pY",
      "https://youtu.be/VMCfmzbysrM",
      "https://youtu.be/T89WUp4GXeQ",
      "https://youtu.be/waozEemllvA",
    ] 
  ),
  Song(
    title: "GRANDES COSAS",
    text: """
CANCIÓN: Grandes cosas - Fernandinho
TONALIDAD: Am    (original: A#m)
TIEMPO: 75bpm

INTRO: // Am - G - F //
            Am
Tú eres el Dios de esta tierra
         G 
eres el rey de este pueblo
         F                Dm
Jesús señor de naciones tu eres
            Am
Tú eres la luz de este mundo 
           G
esperanza para los perdidos 
           F               Dm
tu das la paz al cansado tu eres

PRE-CORO: 
     C      G     F
//Nadie es como nuestro Dios
   Am     G      F           G
nadie es como nuestro rey //

CORO:
     F        
///grandes cosas va ocurrir
  G                         
grandes cosas va acontecer 
        C - G - F
este lugar ///
  F
grandes cosas va ocurrir 
  G                       
grandes cosas va acontecer
// Am G F //
 aquí
""",
    tonalidad: "Am",
    tiempo: 70,
    instrument: 0,
     
    youtubeLink: "https://youtu.be/9RA4RzfEuSg", 
  ),
  Song(
    title: "HAY PODER - NO DARÉ",
    text: """
CANCIÓN: HAY PODER - HIMNO
TONALIDAD: D
TIEMPO: 65bpm

       D         A           D 
Hay poder en la sangre de Jesús
       D         G         A
hay poder sobre todo majestad
       G           A
solo tienes que creer
   F#m         Bm
y abrir tu corazón
       G            A        D
Hay poder en la sangre de Jesús

CANCIÓN: NO DARÉ - HIMNO
TONALIDAD: D
TIEMPO: 65bpm 

      D            A	          D
No daré mi vida a nadie mas que a él
      D            G              A
No daré mi vida a nadie mas que a él
      G            A 
No daré mi vida a nadie mas
     F#m          Bm
No daré mi vida a nadie mas
        G          A          D
porque solo tu la puedes sostener
*se repiten las notas solo cambia 
"vida" por "tiempo" Y "amor" *
""",
    tonalidad: "D",
    tiempo: 65,
    instrument: 0,
     
  ),
  Song(
    title: "HAZ LLOVER",
    text: """
CANCIÓN: Haz llover - JLR
TONALIDAD: Am
TIEMPO: 72bpm

INTRO:  Am - G - Dm - Em - F 

VERSO 1
        Am                G
Haz llover, sobre este lugar,
                  Dm
sediento estoy de Ti.
Dm  Em F                        Am
Ven y sacia hoy la sed que hay en mí,
            G
Lléname de Ti,
             Dm          F                
Ven que necesito que refresques 
         Am    F
mi interior.

VERSO 2
Am                     G
Ven que quiero más de Ti,
                   Dm
Haz me rebozar mi copa hasta sentir,
Dm Em F                          
Tu presencia estremeciendo 
        Am
mi interior,
          G
Ven y tócame,
       Dm           F           Am G
y abrázame, envuelveme en ti Señor.

CORO
C              G
  Tu lluvia está cayendo,
Dm          Am
  Tu gloria descendiendo,
C              G            F
  Tu fuego está ardiendo en mí.
C              G
  Tu lluvia está sanando,
Dm          Am
  Tu gloria restaurando,
C             G             F
  Tu fuego está, hoy sobre mí.

*Primera vez vuelve al verso 2*
*Segunda vez guitarra y otra vez coro*

PUENTE:
   C    G     Dm  Am    C   G     F
//Llu..via    Ca...e,  hoy sobre mi//

""",
    tonalidad: "Am",
    tiempo: 72,
     
    multitrackLink: "https://youtu.be/qppSx0Tk9ms",  
    youtubeLink: "https://youtu.be/m0JZ2U-bgy0", 
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/RwdFhuu183E",
    ],
    guitarLink: [
      "https://youtu.be/ldNRfxNVzc8",
      "https://youtu.be/uXXYx-0440s",
      "https://youtu.be/mf08Y4jwg1E",
    ],
    pianoLink: [
      "https://youtu.be/KEL4SpKN04o",
      "https://youtu.be/ibD1ym7f7jY",
      "https://youtu.be/V_IkQVShQCU",
      "https://youtu.be/GIE13jdDqyA",
    ],
    drumsLink: [
      "https://youtu.be/GuyzT9SSZsI",
      "https://youtu.be/FLvkKIcvKiY",
      "https://youtu.be/ZoxYKbgb1Nc",
      "https://youtu.be/jTG-2z8YI7k ",
    ]
  ),
  Song(
    title: "HE DECIDIDO",
    text: """
CANCIÓN: He decidido seguir a Cristo - Himno
TONALIDAD: D
TIEMPO: 60bpm

INTRO: D - Bm - G - A

VERSO 1
        D             Bm
He decidido seguir a Cristo
        G              A
he decidido seguir a Cristo
        D             Bm 
he decidido seguir a Cristo
             G       
no vuelvo atrás, 
     A7      D  G7 - D
no vuelvo atrás

VERSO 2
          D                  Bm
Si otros vuelven  yo sigo a Cristo
          G                   A
si otros vuelven  yo sigo a Cristo
             G      
no vuelvo atrás, 
     A7      D  G7 - D
no vuelvo atrás

VERSO 3
           D                 Bm
la cruz delante y el mundo atrás
          G                   A
la cruz delante y el mundo atrás
             G      
no vuelvo atrás,
     A7      D  G7 - D
no vuelvo atrás
""",
    tonalidad: "D",
    tiempo: 60,      
     
    youtubeLink: "https://youtu.be/WHVAa74cXjM",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/jHuhsPiJs1A",
    ],
    guitarLink: [
      "https://youtu.be/EhD2qQXGMH8?si=VyNW5XCu_N-NqNfM",
    ],
    pianoLink: [
      "https://youtu.be/q5tgENVXPtQ",
      "https://youtu.be/ltBISv-cL0o",
    ],
  ),
  Song(
    title: "HERMOSO ERES",
    text: """
CANCIÓN: Hermoso eres - Marcos Witt
TONALIDAD: E
TIEMPO: 116bpm

INTRO: // A - D - E //

A             D               E
// En mi corazón hay una canción
A       D            E
Que demuestra mi pasión
F#m      E    D     A  Bm
Para mi Rey y mi Señor
        A           E
Para Aquél que me amó //

CORO
 A         C#m  D      E
// Hermoso eres, mi Señor
 A        C#m       D     E
  Hermoso eres Tú, Amado mío
Bm                          E
   Tú eres la fuente de mi vida
Bm       C#m   D          E
   Y el anhelo de mi corazón //
""",
    tonalidad: "E",
    tiempo: 116,
     
    multitrackLink: "https://youtu.be/LBTWbsMpH48",  
    youtubeLink: "https://youtu.be/Woa4sMqKVmI", 
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/VyuEz_w5KwQ",
      "https://youtu.be/yzjZCV0-4Lw",
    ],
    guitarLink: [
      "https://youtu.be/lmzJ0noX3lk",
      "https://youtu.be/z5pcK-O3iS8",
      "https://youtu.be/-iqOlvk9Csc",
      "https://youtu.be/Q1f6akg5KWk",
      "https://youtu.be/nnRkiqqIvp4",
    ],
    pianoLink: [
      "https://youtu.be/KeD76aG_YDA",
      "https://youtu.be/gsmpJ6UPhog",
      "https://youtu.be/01QK07RBqwA",
      "https://youtu.be/hdxxkKihJpY",
    ],
    bassLink: [
      "https://youtu.be/FqFRQ7MUrGY",
      "https://youtu.be/vpL4GLcTWZc",
    ],
    drumsLink: [
      "https://youtu.be/5AfmKOFIp08",
      "https://youtu.be/go-wGr34Cks",
      "https://youtu.be/KvVCNQxldDw",
    ]
  ),
  Song(
    title: "LA BONDAD DE DIOS",
    text: """
CANCIÓN:  La bondad de Dios -
Cales Louima  y  Matty Martínez
TONALIDAD: G
TIEMPO: 70bpm

INTRO: // G - C //

VERSO 1
         G 
Te amo Diós
     C            G       D/F#m
Tu amor nunca me falla
        Em         C       D 
Mi existir en Tus manos está
                         Em      C 
Desde el momento que despierto
              G D/F# Em
Hasta el anochecer
         C     D             G 
Yo cantaré de la bondad de Dios

CORO
C                       G    D 
  En mi vida has sido bueno
C                      G        D 
  En mi vida has sido tan, tan fiel
C                        G D/F# Em
  Con mi ser, con cada aliento
         C    D              G 
Yo cantaré de la bondad de Dios

VERSO 2
        G 
Amo Tu voz
         C             G      
Me has guiado por el fuego
   D/F#m    Em     C         D
Tú cerca estas en la oscuridad
                Em    C 
Te conozco como Padre
         G D/F# Em
Y como amigo fiel
          C     D              G 
Mi vida está en la bondad de Dios

PUENTE
G/B              C 
   Tu fidelidad sigue
 D           G 
Persiguiéndome
G/B              C 
   Tu fidelidad sigue
 D           G 
Persiguiéndome
     G/B
Todo lo que soy
          C  
Te lo entrego hoy
   D          Em
A Ti me rendiré
G/B              C 
   Tu fidelidad sigue
 D           G 
Persiguiéndome
""",
    tonalidad: "G",
    tiempo: 70,
     
    multitrackLink: "https://youtu.be/xb9tz6mij5E",  
    youtubeLink: "https://youtu.be/SnIzImY9wO4", 
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/MSHXFaD96N8",
      "https://youtu.be/NU2PiPkbbcM",
      "https://youtu.be/exqxOeRz8Zg",
      "https://youtu.be/RFmCwWqs9Xw",
      "https://youtu.be/dvVdYAItZRE",
    ],
    guitarLink: [
      "https://youtu.be/OnK0ohdQKfg",
      "https://youtu.be/C4zUp_Um5Y4",
      "https://youtu.be/ib_zf5M5MMs",
      "https://youtu.be/Mjy_jYELs8Q",
    ],
    pianoLink: [
      "https://youtu.be/t64JL6rT1NM",
      "https://youtu.be/zLc-lincSdk",
      "https://youtu.be/x7jWOyKC8d0",
      "https://youtu.be/_EB1TlstLx8",
    ],
    bassLink: [
      "https://youtu.be/kS8p4qX_Q7Q?si=WM37VgqtPvptmKFO",
    ],
    drumsLink: [
      "https://youtu.be/T2DYr3pY9Kk?si=MuqCl3jsySRWGiq9",
    ]
  ),
  Song(
    title: "LA NIÑA DE TUS OJOS",
    text: """
CANCIÓN: La niña de tus ojos - 
Daniel Calveti
TONALIDAD: C
TIEMPO: 68bpm

INTRO: // C - G - Am - F //
            C                  G
//Me viste a mi cuando nadie me vio
          Am                    F
Me amaste a mi cuando nadie me amo//

PRE-CORO:
              C                G
//Y me diste nombre yo soy tu niña
               Am  
La niña de tus ojos 
                     F
por que me amaste a mí//

CORO:
             C                 G
//Me amaste a mí, Me amaste a mí,
            Am               F
Me amaste a mí, Me amaste a mí//

PUENTE:
  C                           G                         
////Te amo más que a mi vida, 
                         Am
te amo más que a mi vida
                           F
Te amo más que a mi vida, más////
""",
    tonalidad: "C",
    tiempo: 68,
     
    youtubeLink: "https://youtu.be/q9O82hAbWyY", 
    instrument: 1,
    guitarLink: [
      "https://youtu.be/o_USFKQD8EQ",
    ],
    pianoLink: [
      "https://youtu.be/Y7psMchQk_M",
      "https://youtu.be/6Jg7p49WXAw",
      "https://youtu.be/Ix9W4_sNiTM",
    ],
    bassLink: [
      "https://youtu.be/8kWir-SfAVc",
    ],
    drumsLink: [
      "https://youtu.be/KiZthSbxgKk",
      "https://youtu.be/1VWXEbZli1s",
    ]
  ),
  Song(
    title: "LA ULTIMA PALABRA",
    text: """
CANCIÓN: La última palabra - Daniel Calveti
TONALIDAD: D
TIEMPO: 60bpm

INTRO: D - Bm - G - A
   D 
//Dame de tu eterna paz
Bm
  Dame el don para esperar
G               Em
  Ayúdame a confiar en ti
             G 
Porque mis fuerzas no
       A
Puedo más//

CORO
G                D    Dsus4 
//Tú eres mi sustento
G            D   Dsus4 
  Tú mi creador
G                   D 
   Y la ultima palabra
           A    Asus4  A
La tienes tú//
""",
    tonalidad: "D",
    tiempo: 60,
     
    youtubeLink: "https://youtu.be/pKaJm1ZzyDI",
    instrument: 1,
    pianoLink: [
      "https://youtu.be/XbXwXOgFfZk",
      "https://youtu.be/XbXwXOgFfZk",
    ], 
  ),
  Song(
    title: "LIBRE",
    text: """
CANCIÓN: Libre - MSM
TONALIDAD: Am
TIEMPO: 78bpm

INTRO: // Am - F - C //
Am          F               C
Donde el Espíritu de Dios está
 Am        F    C
Hay libertad, puedo adorar
Am         F                C
Todas mis culpas y maldades fueron
   Am            F    C
Borradas en la cruz, libre soy.

PRE-CORO:
F              G
Perdonado soy solo por tu amor
       Am
No hay más condenación
  G
Cristo me libertó.

CORO:
Am                 F
Caen las murallas caen
             C                   G
Las cadenas Dios destruyó libre soy
Am                  F
Libre Dios me hizo libre
              C
El venció la muerte por mi
       G          (Intro)
Libre soy, libre soy.

PUENTE:
       Am       F
///Se rompen cadenas
    C           G
No soy esclavo mas
    Am          F
En Cristo soy libre
        C           G    (Final: F)
No hay más condenación///
""",
    tonalidad: "Am",
    tiempo: 78,
     
    multitrackLink: "https://youtu.be/aWFgClssWI8?si=MxxBciAMVCvB8l7-",  
    youtubeLink: "https://youtu.be/oRlSy7lwWTY",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/WhjZ4bBV8uY?si=CSZg784vLaTKOWOU",
      "https://youtu.be/k1s57UR-hhs?si=CayF4L7OX_CJQS_I",
      "https://youtu.be/zLFoqOoMNFw",
    ],
    guitarLink: [
      "https://youtu.be/XzfayDQ33Ho?si=CZyHBZiwiLv5fZo3",
      "https://youtu.be/CChQ8uctE5Y?si=F1VoQhB_kKzxpiDJ",
      "https://youtu.be/rEKWu71g250",
      "https://youtu.be/oKIxFaMovz8",
      "https://youtu.be/rEft2cFtJ5U",
    ],
    pianoLink: [
      "https://youtu.be/UVo_GXQD2H0?si=v6D4GXptTdrEZ0df",
      "https://youtu.be/U725cip1uaw?si=1SMPJF00l7n4UZXN",
      "https://youtu.be/Nt6b9_-na-0",
      "https://youtu.be/8CIW0M7oWmc",
      "https://youtu.be/EoclJIZfkdY",
    ],
    bassLink: [
      "https://youtu.be/0t9055DX8zo?si=Ealpc_-CJlGJvB8p",
      "https://youtu.be/6VIUsPeWh-Y?si=9dJGBo3ig1iX7VS2",
      "https://youtu.be/rdyrjQPCnPI",
      "https://youtu.be/h2v30WWNxRM",
    ],
    drumsLink: [
      "https://youtu.be/WO6z9lZ3nWQ?si=xMnEz1nk3NjpimIF",
      "https://youtu.be/4vwigQt8ce0?si=Cn0w2jKw0BOa4OYY",
      "https://youtu.be/HSBF9FjYcy4",
      "https://youtu.be/uylPYBN9oPI",
      "https://youtu.be/C_39QT3dZzY",
    ] 
  ),
  Song(
    title: "LLEVAME A TUS ATRIOS",
    text: """
CANCIÓN: Señor llévame a tus atrios - 
Palabra en acción
TONALIDAD: Em
TIEMPO: 60bpm

INTRO: (notas del coro)
       Em
señor llévame a tus atrios
G               D
al lugar santo, al altar de bronce
           C             B7
señor, tu rostro quiero ver
    Em
pasaré la muchedumbre
              G
por donde el sacerdote canta
       D
tengo hambre y sed de justicia
          C            B7
y solo encuentro un lugar.

CORO

 C    D     G               D
lle - va - me al lugar santísimo
        C             D         G   D
por la sangre del cordero redentor
 C    D     G               D
lle - va - me al lugar santísimo
    C         D         Em
tócame, límpiame, heme aquí.
""",
    tonalidad: "Em",
    tiempo: 60,
     
    youtubeLink: "https://youtu.be/YplGejNhmx0",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/JuBq0Kb9S8s",
      "https://youtu.be/Wg7ANkTo-wc",
    ],
    pianoLink: [
      "https://youtu.be/8rE0hK4IrSs",
      "https://youtu.be/DRVwwa7y3aw",
    ],
    bassLink: [
      "https://youtu.be/1OpbXPXlaV0",
      "https://youtu.be/qmxMKvkYhNc",
    ],
    drumsLink: [
      "https://youtu.be/nlRQmTihMRM?si=1vA6c81Hhh7Hld_G",
    ] 
  ),
  Song(
    title: "LIBRE SOY",
    text: """
CANCIÓN: Libre soy - MCLV
TONALIDAD: Dm
TIEMPO: 65bpm 

INTRO: // Dm Bb F C//
Dm        Bb         F
   Libre soy por la sangre
      C
de Jesús
Dm           Bb         
  todo mis pecados
     F             C
mi pasado el perdonó
Dm           Bb
   ya no habrá
   F            C
en mi mas el temor
         Dm
con su amor
    C    Bb
me perdonó

CORO
    Dm
Se rompen las cadenas
    Bb
se rompen las cadenas
    F
se rompen las cadenas
       C
libre soy
""",
    tonalidad: "Dm",
    tiempo: 65,
     
  ),
  Song(
    title: "ME DISTE TODO",
    text: """
CANCIÓN: Me diste todo - 
Marco Barrientos
TONALIDAD: Dm  (original: C#m)
TIEMPO: 65bpm

INTRO: // Dm F C Bb - Dm F Gm //
Dm                         F
//Miro a tus ojos veo tu amor
            C              Dm
Miro a tus manos veo mi perdón
            Dm               F
Miro a la cruz me veo en Tu rostro
        Gm         Dm
Lo que anhelo eres tú //

CORO:
        Bb     F      C      
Tu esperanza me alcanzó 
      Bb    F       C
me sanaste con tu amor
            Bb
Abriste la puerta de tu corazón
             F                C
Me diste la vida me diste perdón
*vuelve una vez al intro*
""",
    tonalidad: "Dm",
    tiempo: 65,
     
    youtubeLink: "https://youtu.be/1qWRFaW1Xqc",
    instrument: 1,
    pianoLink: [
      "https://youtu.be/_7LHGRQaUAE",
    ],
  ),
  Song(
    title: "NADIE COMO TÚ",
    text: """
CANCIÓN: Nadie como tú - MSM ft. Barak
TONALIDAD: E
TIEMPO: 74bpm

INTRO:// A - B - E/G# - C#m - B//
A                 B   E/G#
  Me cautiva tu amor
             C#m        B         A
Solo quiero quedarme aquí a tus pies
                 B    E/G#
Mi refugio eres tú
                C#m    B
Mi escondite es tú Presencia
 A                  B
Solo quiero ver Tu rostro
        E/G#           C#m     B
Y contemplarte y contemplarte
A                    B
Tienes toda mi atención
          E/G#
Vengo a adorarte
           C#m     B
Vengo a adorarte

CORO:
 A              B
Nadie como Tú, Nadie como Tú
C#m                    E
Grande y poderoso, Mi padre amoroso
A              B
Nadie como Tú, Nadie como Tú
C#m                       E
Fiel y Verdadero, El que venció 
en el madero

REPITE INTRO, ESTROFA Y CORO.

PUENTE: (X5)
A -  B  -  E/G#
Jeeeeeeeeeeesús
    C#m - B
Jeeeeeéeeeeesús
""",
    tonalidad: "E",
    tiempo: 74,
     
    multitrackLink: "https://youtu.be/bmWDl_erhE4",  
    youtubeLink: "https://youtu.be/qhl4FGcl_Mo",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/5XyB-IiRzqY",
      "https://youtu.be/FKj6EmZBVBY",
      "https://youtu.be/bi4eS21dx9s",
    ],
    guitarLink: [
      "https://youtu.be/QQeFu_qSA48",
      "https://youtu.be/3PM6Q06XHaA",
      "https://youtu.be/nTIKHpwCyPM",
      "https://youtu.be/lxXh3JCb3kM",
      "https://youtu.be/S-CKEv-DGXQ",
    ],
    pianoLink: [
      "https://youtu.be/T0J3dkOVNgc",
      "https://youtu.be/i8Xr6Pltbs0",
      "https://youtu.be/JvmfibGQaH4",
      "https://youtu.be/ybvRTaH9MeY",
      "https://youtu.be/Rbe6u2r3eLM",
    ],
    bassLink: [
      "https://youtu.be/VOPb2x7P_pk",
      "https://youtu.be/cAXxioaqV1w",
    ],
    drumsLink: [
      "https://youtu.be/2rSSTce-U6M",
      "https://youtu.be/NUKRNlUmPcM",
      "https://youtu.be/pToS8qYiWjA",
      "https://youtu.be/ZXzQqNSTLtw",
    ] 
  ),
  Song(
    title: "NO BASTA",
    text: """
CANCIÓN: No basta - JCA
TONALIDAD: D
TIEMPO: 114bpm

INTRO:// G - A - F#m - Bm - G A D //

G     A         F#m    Bm      
  No basta solo con cantar,  
G           A        F#m  Bm    
  no basta solo con decir
G             A     F#m               
  No es suficiente solo  
           Bm
  con querer tener  
A - G       A       D
    es necesario morir.
G     A              F#m   Bm     
  No basta solo con soñar,       
  G           A        F#m  Bm    
  no basta solo con pedir
G             A     F#m              
  No es suficiente solo 
          Bm
  con querer tener    
A - G       A       D
    es necesario morir.

CORO
G          A   F#m           Bm
  Dame tu vida,   esa clase de vida 
  que sabes dar
G          A   F#m           Bm
  Dame tu vida,   yo quiero vivir 
  solo para ti
G          A   F#m       Bm
  Dame tu vida, resucítame en ti
G             A              D
  Yo quiero vivir solo para ti.
""",
    tonalidad: "G",
    tiempo: 114,
     
    youtubeLink: "https://youtu.be/YGTZVv_Lrwk",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/niDSKgMhXvc",
    ],
    guitarLink: [
      "https://youtu.be/RO9X8ycA-5c",
    ],
    pianoLink: [
      "https://youtu.be/PwT0M7cPf5g",
      "https://youtu.be/mokxvUzcfSg",
      "https://youtu.be/YUQHvJzQQwQ",
    ],
    drumsLink: [
      "https://youtu.be/jyyw4D3EmMo",
    ] 
  ),
  Song(
    title: "NO HAY LUGAR MÁS ALTO",
    text: """
CANCIÓN: No hay lugar más alto - 
MSM ft. Christine D'Clario
TONALIDAD: A
TIEMPO: 68bpm

INTRO: // A - D //
        A              E/G# 
a tus pies arde mi corazón
       F#m                 D
a tus pies entrego lo que soy
       A              E/G# 
Ese lugar de mi seguridad
      F#m                 D
Donde nadie me puede señalar

PRE-CORO
         D     
Me perdonaste, 
                      E
me acercaste a tu presencia
        F#m7    
Me levantaste, 
                  E/G# 
hoy me postro a adorarte

CORO
          A/C#      D         E
//No hay lugar más alto, más grande
                F#m7    
Que estar a tus pies, 
                A/C# 
que estar a tus pies //

PUENTE
     D           E    
Y aquí permaneceré, 
     A   E     F#m7
postrado a tus pies
     D           E   
Y aquí permaneceré 
              F#m7       A
a los pies de Cristo   Oouoh...
""",
    tonalidad: "A",
    tiempo: 68,
     
    multitrackLink: "https://youtu.be/vjAu9F3zZUg",  
    youtubeLink: "https://youtu.be/UbEUeFC3lh4?si=6qrauTIvlM7TwV0_",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/HrFCDXPjXjU",
      "https://youtu.be/WtCtzC7214s",
      "https://youtu.be/WE4TA8Niy1U",
      "https://youtu.be/gXaCXbpQ9Pg",
    ],
    guitarLink: [
      "https://youtu.be/U5GT7cq90_E",
      "https://youtu.be/77kraRhWG3M",
      "https://youtu.be/x04Vsq46-Qk",
      "https://youtu.be/STuXm9xSTuY",
      "https://youtu.be/x04Vsq46-Qk",
    ],
    pianoLink: [
      "https://youtu.be/TrV46__pYfc",
      "https://youtu.be/xGG-_aA-mZo",
      "https://youtu.be/CeJWptV6rEw",
      "https://youtu.be/mQzbrK5mVpU",
      "https://youtu.be/U8H6E1ePE70",
    ],
    bassLink: [
      "https://youtu.be/vVP39BvVjTE",
      "https://youtu.be/bzHnjgOCxnY",
      "https://youtu.be/yResAsMYAzI",
    ],
    drumsLink: [
      "https://youtu.be/YjwzTmhm2Yw",
      "https://youtu.be/8PvcymQtmx8",
      "https://youtu.be/ma_S7E0Ko5k",
      "https://youtu.be/_AtvFYjqGZc",
    ] 
  ),
  Song(
    title: "NO HAY NADIE COMO TÚ",
    text: """
CANCIÓN: No hay nadie como tú -
Marco Barrientos
TONALIDAD: G
TIEMPO: 62bpm

   G     D    Em
Señor aquí estamos
     D    C
para adorarte
          D
para exaltarte
   G      D  Em
Señor, reconocemos
           D      C
que no hay nadie como Tú
            D
y hoy te cantamos

CORO
  G                      D
//no hay nadie como Tú
 Em                      D
  no hay nadie como Tú
    C                    G
precioso y glorioso
    Am              D
tan bello y tan hermoso//

PUENTE
   G  D   Em
Jesús  Jesús
    D        C
precioso Jesús
  G    Am D
yo te adoro 
   G  D   Em
Jesús  Jesús
    D        C
precioso Jesús
  G  Am D
yo te amo 

VERSO 2
G                  D
   hemos venido
Em                 D
   a ministrarte
C
 y a exaltarte
    Am               D
precioso Cordero de Dios
G                  D
   en este canto
Em                        D
   yo te entrego mi amor
C 
  para ministrarte
      Am             D
y que todo el mundo sepa que
*vuelve al coro*
""",
    tonalidad: "G",
    tiempo: 62,
    youtubeLink: "https://youtu.be/UqZ-Lvl6_Dc",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/hZjs4lw7ddQ",
      "https://youtu.be/8FObhYjicAE",
      "https://youtu.be/NFxr08Ld9R8",
    ],
    pianoLink: [
      "https://youtu.be/0e1f9UsnpEQ",
      "https://youtu.be/6zU5Dim4i44",
    ],
    drumsLink: [
      "https://youtu.be/EwJHYBdWd8I",
      "https://youtu.be/arY-VVh3JMg",
    ] 
  ),
  Song(
    title: "OCÉANOS",
    text: """
CANCIÓN: Océanos - HILLSONG UNITED
TONALIDAD: Bm
TIEMPO: 132bpm
INTRO: Bm - A/C# - D - A - G

VERSO 1
Bm               A/C# D
  Tu voz me llama a las aguas
            A          G
Donde mis pies pueden fallar
Bm                      A/C# D
   Y ahí te encuentro en lo incierto
    A          G
Caminaré sobre el mar

PRE-CORO
G       D           A
  A tu nombre clamaré
G           D        A
  En ti mis ojos fijaré
          G
En tempestad
         D        A
Descansaré en tu poder
           G     A      (INTRO)
Pues tuyo soy hasta el final

VERSO 2
Bm                   A/C# D
  Tu gracia abunda en la tormenta
          A         G
Tu mano Dios, me guiará
Bm                   A/C#  D
  Cuando hay temor en mi camino
      A                G
Tú eres fiel y no cambiarás

PUENTE
Bm                      G
///Que tu Espíritu me guíe sin fronteras
       D
Más allá de las barreras
   A
A donde tú me llames
Bm                    G
  Tú me llevas más allá de lo soñado
       D
Donde puedo estar confiado
      A
Al estar en tu presencia///
""",
    tonalidad: "Bm",
    tiempo: 132,
    multitrackLink: "https://youtu.be/nVDnAnLgnhY",  
    youtubeLink: "https://youtu.be/2BJ0OA0nXPY?si=k7eR-UGDlv7ek8eV",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/jGs0uyxWRBY?si=U8XLfzwh06Bu5d-z",
    ],
    guitarLink: [
      "https://youtu.be/gwm4NFll7oA",
      "https://youtu.be/CZuMqR6Smuc",
      "https://youtu.be/3KjLPcErz3g?si=bsam9bKjfTs5eREC",
      "https://youtu.be/WpwviSogi0M?si=JyCHDjYPAm-afmkF",
      "https://youtu.be/CpUE6nZ6lQE?si=KFMXEJw4Qywljaa0",
    ],
    pianoLink: [
      "https://youtu.be/0Lfx8unh2JI",
      "https://youtu.be/1ztOdqLAzdM",
      "https://youtu.be/1ztOdqLAzdM",
      "https://youtu.be/cCyKw8eBi88?si=4VaVN764lmiiJdoh",
    ],
    bassLink: [
      "https://youtu.be/9CwEdqKB3xI?si=qVvqSO7R5vGaKNnX",
      "https://youtu.be/qOHs5HW4EkM?si=OrQ525kMvkFkDAJj",
    ],
    drumsLink: [
      "https://youtu.be/TAZih3SNCCE",
      "https://youtu.be/pTM1xCp_eFw",
      "https://youtu.be/xsLEBOvv0vs?si=qsPe9VcQGGJlHEAR",
      "https://youtu.be/c94XzXGBmkQ?si=zUrpuE-Qrqewrwe1",
    ] 
  ),
  Song(
    title: "PERDÓN",
    text: """
CANCIÓN: Perdón - Marco Barrientos
TONALIDAD: D(IGLESIA) - E(ORIGINAL)
TIEMPO: 75bpm
INTRO: *PIANO* 
D2 - A2 - G/Em - A - A/G - F#m - Bm
Em - Asus - A - D2 - G - A
      D     A       D    G - A   
//Perdón Jesús, perdón    
    D   A    Bm   F#m
Perdóname  Señor
    G             A       
Yo sé que débil fui,   
    F#m           Bm
Te herí Y te lastimé
    G   A    D     G-A
Perdóname Señor //

CORO
     G           A
Mas hoy en tu misericordia
 F#m         Bm 
Quiero descansar,
    G                A        D    A
Sé que tu sangre me puede limpiar
    G               A       F#m   Bm 
Con arrepentimiento en mi corazón
     G           A       D
Me humillo y te pido perdón.
""",
    tonalidad: "D",
    tiempo: 75,
    youtubeLink: "https://youtu.be/JcBaKhdmwTo?si=UzCBbVezbEtEs8oC",
  ),
  Song(
    title: "PRECIOSA SANGRE",
    text: """
CANCIÓN: Preciosa Sangre - 
Marco Barrientos ft. Julio Melgar
TONALIDAD: Bm
TIEMPO: 70bpm

INTRO: Bm - A - F#m - C#m

VERSO 1
Bm          A             F#m C#m
  Preciosa sangre se derramó
Bm          A                F#m C#m
  Preciosa sangre fluyó por amor
Bm               A
  Sobre ti el dolor
F#m              D
  Tus venas lloraron
   A     F#m    C#m    E
Jesús, Jesús, Jesús.

CORO
D                  A
  Hay poder en la sangre
F#m               E
  Que fluyó por amor
D                   A
  Hay poder en la sangre
             E
Que Él derramó.

VERSO 2
Bm          A             F#m C#m
  Preciosa sangre me purificó
Bm          A       
  Preciosa sangre 
                F#m C#m
  que me transformó
Bm               A
  Sobre ti el dolor
F#m              D
  Tus venas lloraron
   A     F#m    C#m    E
Jesús, Jesús, Jesús.
( CORO )

INSTRUMENTAL:// Bm A F#m C#m //

PUENTE
      Bm        F#m
//Tu sangre me transformó
     D        A    E
Tu sangre me perdonó
     Bm   F#m
Tu sangre me limpió
    C#m/E
Tu sangre me sanó
    E
Tu sangre me sanó//
(CORO)
""",
    tonalidad: "Bm",
    tiempo: 70,
    multitrackLink: "https://youtu.be/2XC4QiMP3qA",  
    youtubeLink: "https://youtu.be/6gO9rCFJ1wk",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/nNcPFClVYT4",
      "https://youtu.be/xXgptViW0Gs",
      "https://youtu.be/0YE21b3juXc",
    ],
    guitarLink: [
      "https://youtu.be/XuuikDF8m2o",
      "https://youtu.be/6EnxqdXKN_k",
      "https://youtu.be/4rJRR6o-LbY",
      "https://youtu.be/NQYoArmRzPs",
    ],
    pianoLink: [
      "https://youtu.be/iPq4uVnDytw",
      "https://youtu.be/bp3cMUirYNY",
      "https://youtu.be/l5fd-xvEL3M",
      "https://youtu.be/HHPNwYKOOHs",
    ],
    bassLink: [
      "https://youtu.be/91c_2st-Le0",
      "https://youtu.be/beFApEQTmLQ",
    ],
    drumsLink: [
      "https://youtu.be/2exKYHGmKDo",
      "https://youtu.be/ai6F6xMyA0M",
      "https://youtu.be/GxmbUyBhNLQ",
      "https://youtu.be/JJEgag7omH8",
    ] 
  ),
  Song(
    title: "QUE SERÍA DE MI",
    text: """
CANCIÓN: Que sería de mi - JAR
TONALIDAD: F#..... G
TIEMPO: 109bpm

INTRO: F# - B - C#
F#               C#                   
   Que sería  de mí si no me 
             B
   hubieras alcanzado
F#               C#                    
   Donde estaría hoy si no me 
             B
   hubieras perdonado
    F#                  C#
Tendría un vacío en mi corazón.
    D#m                  B
Vagaría sin rumbo y sin dirección.

         F#           C#               
//Si no fuera por tu gracia 
             B
  y por tu amor//
 
  G#m                  D#m  
Sería como un pájaro herido 
                    C#
que se muere en el suelo.
  G#m                     D#m  
Sería como un ciervo que brama 
                   C#
por agua en el desierto.

          B           C#              
//Si no fuera por tu gracia 
           F#
y por tu amor//


*Sube medio tono*
G               D         
 ¿Qué sería de mí si no me 
           C
 hubieras alcanzado,
G                D                     
 ¿Dónde estaría hoy si no me 
            C
 hubieras perdonado,
     G                  D
Tendría un vacío en mi corazón,
     Em                 C
Vagaría sin rumbo, sin dirección.

         G             D               
//Si no fuera por tu gracia 
             C
  y por tu amor//

    Am                    Em7 
//Sería como un pájaro herido 
                  D
que se mueren el suelo
  Am                      Em7  
Sería como un ciervo que brama 
                   D
por agua en el desierto.

Bm7       C             D              
   Si no fuera por tu gracia 
            Em7
   y por tu amor,
        C            D              
Si no fuera por tu gracia 
               G
    y por tu amor//
""",
    tonalidad: "F#",
    tiempo: 109,
    multitrackLink: "https://youtu.be/NHZpNPsPtOg",  
    youtubeLink: "https://youtu.be/rB92Hl2dg3c?si=g43A5lJ_VYnQps7T",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/_Q9jZsO8D0w",
      "https://youtu.be/n0nZytq8DyA",
    ],
    guitarLink: [
      "https://youtu.be/EoaioYxP8g0",
      "https://youtu.be/X7t-0We8tWE",
      "https://youtu.be/5qYLQSuJgKI",
      "https://youtu.be/KGQ-91hiW8Y?si=6XixYgmIYdfUsYHs",
    ],
    pianoLink: [
      "https://youtu.be/93M_5P3gZyY",
      "https://youtu.be/NulHdJqUCAg",
      "https://youtu.be/6qQENRi8qUY",
    ],
    bassLink: [
      "https://youtu.be/4F6yGbBlZnw",
      "https://youtu.be/4F6yGbBlZnw",
      "https://youtu.be/jnXp5ZDxPZ8",
    ],
    drumsLink: [
      "https://youtu.be/IKz3iSu35Vs",
      "https://youtu.be/57wQLAKBJ0c",
      "https://youtu.be/iL1LTSggvvk",
    ] 
  ),
  Song(
    title: "RENUÉVAME",
    text: """
CANCIÓN: Renuévame - Marcos Witt
TONALIDAD: D
TIEMPO: 60bpm

    D   G    A     D      G 
Renuévame Señor Jesús
       Em           A
ya no quiero ser igual
    D   G    A     D      G 
Renuévame Señor Jesús
       Em        Asus4    A
pon en mí tu corazón

Coro:
          D           A   
//Porque todo lo que hay 
    Bm    F#m    G
dentro de mi
    Em            D      A        
necesita ser cambiado señor
        D           A               
Porque todo lo que hay 
          Bm     F#m
dentro de mi corazón
G       A          D
   necesita mas de ti//
""",
    tonalidad: "D",
    tiempo: 60,
    youtubeLink: "https://youtu.be/oDq5UZSYaPw",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/9LdRTmokXys",
      "https://youtu.be/BM_6kKCMLlk",
    ],
    guitarLink: [
      "https://youtu.be/BM_6kKCMLlk",
      "https://youtu.be/l9x6LSqOVo0",
    ],
    pianoLink: [
      "https://youtu.be/4pCQ41qyDyQ",
      "https://youtu.be/4pCQ41qyDyQ",
    ],
    bassLink: [
      "https://youtu.be/qeW6bMCq1a8",
      "https://youtu.be/cbiHUyJyyrw",
      "https://youtu.be/_rFWbTsOZao",
    ],
    drumsLink: [
      "https://youtu.be/R1BC44O76_w",
      "https://youtu.be/R1BC44O76_w",
    ] 
  ),
  Song(
    title: "RESTAURARÉ",
    text: """
CANCIÓN: Restauraré hoy el fundamento 
- Carlos Mendoza
TONALIDAD: Dm
TIEMPO: 73bpm

INTRO: // Dm - C - Bb //
VERSO
           Dm  C           Bb
 //Restauraré hoy el fundamento
       Dm     C      Bb
las calzadas restauraré,
       Dm     C         Bb
levantaré muchas generaciones
      Gm         C
y su tierra sanaré
           Dm  C  Bb
dice el señor//

CORO
Dm          Bb            C     F
  //Restauraré lo que comió la oruga
       Bb     C           F
lo que la langosta destruyó
       Dm     C         Bb
levantaré muchas generaciones
      Gm         C
y su tierra sanaré
           Dm  C  Bb
dice el señor//
""",
    tonalidad: "Dm",
    tiempo: 73,
    youtubeLink: "https://youtu.be/dPlMlF0euiM",
    instrument: 1,
  ),
  Song(
    title: "SANTO POR SIEMPRE",
    text: """
CANCIÓN: Santo por siempre - La IBI
TONALIDAD: G
TIEMPO: 70bpm
INTRO: C - Em D - Bm - Em - D - G

VERSO 1:
 G
Mil generaciones
    C          G
Se postran adorarle
       Em        D
Le cantan al cordero
         C
Que venció

VERSO 2:
      G
Los que nos precedieron
   C               G
Y los que en Él creerán
    Em           D
Le cantarán a aquel
            C
Que ya venció

PRE-CORO:
C                      Em
Tu nombre, es más alto
     D
Tu nombre, es más grande
    Em            D    C
Tu nombre, sobre todo es
                      Em
Sean tronos, dominios 
   D
Poderes, postetades
    Em            D   Am7
Tu nombre, sobre todo es

CORO 1:
            C
Claman ángeles
 Em  D
San_to
               Bm7
Clama la creación
    Em
Santo
           Am7
Exaltado Dios
    D
Santo
            G
Santo por siempre

VERSO 3:
G
Si te ha perdonado
    C           G
Y tienes salvación
 Em            D
Cántale al cordero
         C
Que venció

VERSO 4:
 G
Si te ha libertado
    C                   G
Su nombre ha puesto en ti
 Em            D
Cántale al cordero
         C
Que venció

 Em          D        Am
Cantaremos siempre "amén"

(CORO 1)

CORO 2:
                    C
Canta el pueblo al Rey
 Em  D
San_to
            Bm7
Soberano es Él
    Em
Santo
              Am7
Y por siempre es
    D
Santo
            G
Santo por siempre

(PRE CORO) X2
(CORO 1)
(CORO 2)

FINAL:
              Am7
Y por siempre es
    D
Santo
            G     C  G
Santo Por Siempre
""",
    tonalidad: "G",
    tiempo: 70,
    multitrackLink: "https://youtu.be/nsGFuQWvM_o?si=_sr3q7VyqqBWIHV9",  
    youtubeLink: "https://youtu.be/1CxEg0H6Q-4?si=iZtJJknjJz60hNsq",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/tISWnYBasWY?si=_m30CVY3YVvr79Hc",
      "https://youtu.be/_doV8OOjDxI?si=-PEoRNMPJk0pJQdP",
      "https://youtu.be/gTEw3-Fj3VY?si=NYcuvxHl6EWrcm2Q",
    ],
    guitarLink: [
      "https://youtu.be/co_vS34YcgE?si=vkntH-rGutJKof8Q",
      "https://youtu.be/UXrrJ75f5cw?si=NtKYjC6uPc1g6opS",
      "https://youtu.be/iebyf6NY-kY?si=BN4th-k5yd_LdXdA",
      "https://youtu.be/CEqIiaeQOpk?si=h6QyrVUwkJzJgDjI",
    ],
    pianoLink: [
      "https://youtu.be/wSI3gkXC7wo?si=fLGtIE1OV1aMxonb",
      "https://youtu.be/ZQ6vnD39DJw?si=0MpFRsjRDdxQfokC",
      "https://youtu.be/gzOdc51jmFc?si=blQniMP4PqApEcZP",
    ],
    bassLink: [
      "https://youtu.be/lnvYESmQ_lg?si=k5dbYWqysVp7FsVm",
      "https://youtu.be/8idjfFQG5vQ?si=7k2ZwzF6kvcSSNyz",
      "https://youtu.be/e9xK_g_r5Dw?si=xKCMa90JLlSmq_qW",
    ],
    drumsLink: [
      "https://youtu.be/A8q1iCBCV_c?si=Yiwi1Ol9SrNKZQfx",
      "https://youtu.be/1XH8Ia0jy6Y?si=JbQ-t7R9HH88p_qO",
    ] 
  ),
  Song(
    title: "TEMPRANO YO TE BUSCARÉ",
    text: """
CANCIÓN: Temprano yo te buscaré - 
Marcos Witt
TONALIDAD: G
TIEMPO: 119bpm

INTRO: G - C X4

G                      D
  Temprano yo te buscaré
C/B                    Am        D
  De madrugada yo me acercaré a Ti
G                            D   
  Mi alma te anhela y tiene sed
C/G                Am7 Am    D
  Para ver Tu gloria y Tu poder

CORO
G      D              Em  C D
  Mi socorro has sido Tú
       G            D    C        D
En la sombra de tus alas yo me gozaré
G            D           Em
  Mi alma está apegada a Ti
            C                 D
Porque Tu diestra me ha sostenido
Em       C                Am D G
Oh, Tu diestra me ha sosteni...do
""",
    tonalidad: "G",
    tiempo: 119,
    multitrackLink: "https://youtu.be/WhiVlUJNWQQ",  
    youtubeLink: "https://youtu.be/ADt2wYV6cwM",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/DO6lyN03L34?si=D6QBdoztnmpZszwV",
    ],
    guitarLink: [
      "https://youtu.be/TF_Ic9jfojc",
      "https://youtu.be/m697FlCax1U",
      "https://youtu.be/2b3HUzI2mjs",
      "https://youtu.be/XDShbw_Pv6o",
      "https://youtu.be/lcLpOPeBDjI",
      "https://youtu.be/PsVt2JnYPd8",
    ],
    pianoLink: [
      "https://youtu.be/v0TUsKh6puU",
      "https://youtu.be/ndwUcgbGPpM",
      "https://youtu.be/VmZAYpnodOQ",
      "https://youtu.be/8Y6pzNLBNHw",
    ],
    bassLink: [
      "https://youtu.be/9ngKvkFBQAA",
      "https://youtu.be/VSWZhUOtuH0",
    ],
    drumsLink: [
      "https://youtu.be/DpFnyswGz5A",
      "https://youtu.be/Zz_Z3dwJ3ik",
      "https://youtu.be/afsgHD0x1Jo",
      "https://youtu.be/5AYcTJ68yXM",
    ] 
  ),
  Song(
    title: "TU NOMBRE ES SANTO",
    text: """
CANCIÓN: Tu nombre es santo - 
Paul Wilbour
TONALIDAD: Em
TIEMPO: 67bpm

*el intro es instrumental de la canción*
     Em                  D
//Yo entro al lugar más santo
      C          D        Em
a traves del cordero de Dios
  Em                   D
y entro tan solo a adorarte
    C           D         Em
yo vengo a honrrar al yo soy//

CORO
            G      D
//Dios te adoro a ti
     Am     Em
te adoro a ti//

FINAL
   Em                C          
//pues tu nombre es santo, 
 D         Em
santo, oh Dios//
""",
    tonalidad: "Em",
    tiempo: 67,
    youtubeLink: "https://youtu.be/jyhq0n9DJ2Y",
    instrument: 1,
    pianoLink: [
      "https://youtu.be/WVbH2AiN8AE",
      "https://youtu.be/D96FsMQcC-E",
    ],
  ),
  Song(
    title: "TUS CUERDAS DE AMOR",
    text: """
CANCIÓN:  Tus cuerdas de amor -
Julio Melgar ft. Lowsan Melgar
TONALIDAD: Bm (original:Dm)
TIEMPO: 67bpm

INTRO: //// Bm - G  - D ////
Bm               G     D
Aunque pase el tiempo sé
    Bm          G     D
Que tu promesa cumplirás
Bm             G    D
Nada en ti se perderá
Bm           G   D
Esa es mi seguridad
        A
//Tus cuerdas de amor
               D - Bm - F#m
Cayeron sobre mí //

CORO
 G                        D
  //Es tu amor que me sostiene
             Bm                 F#m
El que me levanta, el que me da paz
             G 
Me da seguridad//

FINAL
              Em
De lo que vendrá, 
                 Bm
Tú tienes el control
                      A
Nunca pierdes el control.

VERSO 2
  Bm            G     D
Escucho el eco de tu voz
Bm           G        D
Resonando en mi interior
Bm               G      D
Tus palabras me sostendrán
Bm           G   D
Esa es mi seguridad.
Bm                 G     D
Los velos están cayendo hoy
Bm               G     D
Y puedo ver con claridad
   Bm               G      D
Mi fe se está encendiendo hoy
   Bm             G     D
Y hoy me vuelvo a levantar.
[CORO]
""",
    tonalidad: "Bm",
    tiempo: 67,
    multitrackLink: "https://youtu.be/XZsSLpohNck",  
    youtubeLink: "https://youtu.be/-HJim0x8xVk?si=MXQSF4YlXYm5vHER",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/8OF5XYl786Y",
      "https://youtu.be/ez7wx4JgXiE",
      "https://youtu.be/sc31N9mp3Ns",
      "https://youtu.be/8E-nttA917o",
    ],
    pianoLink: [
      "https://youtu.be/mdmOLY6BWO0",
      "https://youtu.be/Xe45QVToj4c",
      "https://youtu.be/zJOFL0ZpM1w",
    ],
    bassLink: [
      "https://youtu.be/eXqHT6aDqH8",
      "https://youtu.be/mqKKX5ji1mY",
      "https://youtu.be/SoF9c3IdSyU",
      "https://youtu.be/UTfrVmENAJo",
    ],
    drumsLink: [
      "https://youtu.be/v_ng2CJM7k8",
      "https://youtu.be/2sqcWglJMfI",
      "https://youtu.be/HvA37F_oUlA",
      "https://youtu.be/ZJBQbwaqjtU",
    ] 
  ),
  Song(
    title: "UNCIÓN EN EL AIRE",
    text: """
CANCIÓN: Unción En El Aire - 
World Worship ft. Cales Louima
TONALIDAD: Cm
TIEMPO: 140bpm

INTRO:// Cm7 - Eb - Ab //

      Cm7                      
Yo no sé qué tenía Daniel 
            Bb
Que cuando oraba leones callaban
      Fm7               
Yo no sé que tenía Elías
           Ab              G7
Que profetizaba y fuego caía
      Cm7                 
Yo no sé qué tenía Moisés 
                  Bb
Que al bajar del monte              
Él resplandecía
      Fm7               
Yo no sé qué tenía Samuel 
                Ab             Bb
Que la voz del padre él reconocía

PRE-CORO
                  Cm7
//Pero hay una unción en el aire
             Eb      Ab
Y lo que me cueste quiero entregarte
            Eb             
Hoy derramarás tu espíritu 
              G       G7
Y tus hijos profetizarán//

CORO
            Cm7                    
//¡Yo veo señales, yo veo milagros 
    Eb    Ab
Yo veo tinieblas hoy retroceder!
        Eb             G7
Y ese poder está sobre mí//

[SOLO] // Ab - Bb - Fm7 - G7 //

PUENTE 1
                  Cm7       Eb    Ab
////Esa unción llegó, la puedo sentir
         Eb             G7
Y ese poder esta sobre mi////
[ CORO ]
( Cm  Eb  Ab )
( Eb  G  G7 )

PUENTE 2
     Cm7       
[El fuego llego 
            Eb         Ab
Me consumió no soy el mismo
                        Eb
No no no no, no soy el mismo
           G7
No soy el mismo]x6
[ CORO ]

[ PUENTE 1 ]
""",
    tonalidad: "Cm",
    tiempo: 140,
    multitrackLink: "https://youtu.be/4RMGNLcwK28?si=ACsRe4t1CqiPY4Em",  
    youtubeLink: "https://youtu.be/FeeaYB0JGlA",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/pkeRZFyFYYI",
    ],
    guitarLink: [
      "https://youtu.be/dxqSQUBWEdQ",
      "https://youtu.be/xQENz-A4HhQ",
      "https://youtu.be/1DXyPlMpZ8k",
    ],
    pianoLink: [
      "https://youtu.be/1DXyPlMpZ8k",
      "https://youtu.be/N0CxpoT3j_g"
    ],
    bassLink: [
      "https://youtu.be/mxAfGJvzrAE",
    ],
    drumsLink: [
      "https://youtu.be/uh8GY0lUjP4",
      "https://youtu.be/re60gAVRd5A",
    ] 
  ),
  Song(
    title: "VEN ESPÍRITU VEN",
    text: """
CANCIÓN: Ven espíritu ven -
Marco Barrientos
TONALIDAD: D
TIEMPO: 57bpm

   D     A      Bm
//Ven espiritu ven,
   F#m       G 
y llename señor
    Em7           Asus4  A
con tu preciosa unción.//

CORO
     D        A
Purifícame y lávame,
     Bm        F#m        G 
renuévame, restaurame, señor,
Em7         Asus4  A
    con tu poder.
     D        A
purifícame y lávame,
     Bm        F#m      
renuévame, restaurame, 
   G       A         D      
señor, te quiero conocer. 
""",
    tonalidad: "D",
    tiempo: 57,
    youtubeLink: "https://www.youtube.com/watch?v=zkQQPY-vwDw&ab_channel=MarcoBarrientos",
    instrument: 1,
  ),
  Song(
    title: "VINE ALABAR",
    text: """
CANCIÓN: Vine Alabar - Evelyn Caceres
TONALIDAD: D (Cancion: F#)
TIEMPO: 61bpm 

D      A/C#      Bm  F#m
Vine a alabar a Dios,
G         Em7     Asus A 
Vine a alabar a Dios,
D      A/C#       Bm  F#m
Vine a alabar su Nombre.
G          A      D 
Vine a alabar a Dios.

CORO
    G         A 
El vino a mi vida
      F#m          Bm  
en un día muy especial,
    G          A 
cambió mi corazón 
        D         D7/A
por un nuevo corazón

  G            A 
y esa es la razón
   F#m           Bm  
por la que digo que
G         A       D    
vine a alabar a Dios

FINAL
Em7      A        D 
vine a alabar a Dios.
""",
    tonalidad: "D",
    tiempo: 61,
    youtubeLink: "https://youtu.be/p1S24NSxWik",
    instrument: 1,
  ),
  Song(
    title: "YO NAVEGARÉ",
    text: """
CANCIÓN: Yo navegaré - Dahaira
TONALIDAD: Am (Original: G#m)
TIEMPO: 70bpm

INTRO: Am - F - G - Dm - E

VERSO 1
         Am                      G
Yo navegaré, en el océano del espíritu
             F      Dm          E
Y allí adoraré, al Dios de mi amor
        Am         G
Yo adoraré al Dios de mi vida
            F     Dm           E
y ahí adoraré al Dios que me amó 

PRE-CORO
  Am
Espíritu, espíritu
                G
Desciende como fuego
                 F              
Como en pentecostés
   Dm            E
Y lléname de de gozo

CORO
     Am
Lléname, lléname
           G
Con tu presencia lléname, lléname
          F
Con tu poder lléname, lléname
    Dm    E
Con tu amor

VERSO 2
             Am            G
Espíritu de Dios, llena mi vida
          F        Dm    E
Llena mi alma, llena mi ser
""",
    tonalidad: "Am",
    tiempo: 70,
    youtubeLink: "https://youtu.be/5IPfpwtR6n0",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/AGKQ5zpc4WE?si=N9SG3hDt1Em0p-Du",
      "https://youtu.be/ftGA_5zqQ8k?si=6SzseLQalP01xoMt",
    ],
    pianoLink: [
      "https://youtu.be/Oy-QmeQw0vQ?si=0aQ8Yd116t9AjkaD",
    ],
    bassLink: [
      "https://youtu.be/UEvOoG6MmPA?si=tY_wJhv5p5-EAOFp",
    ],
    drumsLink: [
      "https://youtu.be/5baFp3AJ7MM?si=rv4-cTdg7dAVaZeA",
    ] 
  ),
];

// Lista de canciones simplificadas para búsqueda
final List<Song> cancionesSimplificadas = [
  Song(
    title: "ALELUYA",
    text: "hermoso eres Dios tan lleno de amor tu fidelidad me acompañará eres tú mi luz en mi oscuridad mi corazón te anhela cada día más aleluya aleluya santo santo santo eres tú aleluya aleluya digno eres Dios de adoración",
    tonalidad: "Em", // No se necesita
    tiempo: 0, // No se necesita
    status: 1,
  ),
  Song(
    title: "AMAMOS TU PRESENCIA",
    text: "encuentro sanidad encuentro libertad en tu presencia encuentro el perdón encuentro salvación en tu presencia correremos hacia ti el cielo hoy está aquí correremos hacia ti el cielo hoy está aquí amamos tu presencia oh Dios amamos tu presencia oh Dios amamos tu presencia oh Dios amamos tu presencia oh Dios correremos hacia ti el cielo hoy está aquí amamos tu presencia oh Dios amamos tu presencia oh Dios amamos tu presencia oh Dios amamos tu presencia oh Dios amamos tu presencia oh Dios amamos tu presencia oh Dios amamos tu presencia oh Dios amamos tu presencia oh Dios",
    tonalidad: "E",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "CREO EN TI",
    text: "Quiero levantar a ti mis manos Maravilloso Jesús, Milagroso Señor Llena este lugar de tu presencia Haz descender tu poder, a los que estamos aquí Creo en ti, Jesús De lo que harás en mí, en mí, en mí Recibe toda la gloria Recibe toda la honra Precioso hijo de Dios",
    tonalidad: "Bm",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "DE GLORIA EN GLORIA",
    text: "De gloria en gloria te veo Cuanto más te conozco Quiero saber más de ti Mi Dios cual buen alfarero Quebrántame, transfórmame Moldéame a tu imagen Señor Quiero ser más como tú Ver la vida como tú Saturarme de tu espíritu y reflejar al mundo tu amor",
    tonalidad: "D",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "DIOS DE LO IMPOSIBLE",
    text: "Jesucristo, reinas con poder Soberano, victorioso Rey Ni la muerte pudo detener Tu poder para vencer Dios de lo imposible Te adoramos Eres invencible Soberano Tuya es toda la gloria Tuyo es todo el honor",
    tonalidad: "Am",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "DIOS ESTÁ",
    text: "Dios está aquí tan cierto como el aire que respiro tan cierto como en la mañana se levanta tan cierto como yo te hablo y me puedes oír. El Espíritu de Dios está en este lugar El Espíritu de Dios se mueve en este lugar Está aquí para consolar Está aquí para liberar Está aquí para guiar El Espíritu de Dios está aquí Muévete en mí, muévete en mí Toma mi mente y mi corazón Llena mi vida de tu amor Muévete en mí, Dios Espíritu, muévete en mí.",
    tonalidad: "D",
    tiempo: 0,
    status: 1,
  ),
  Song(
    title: "EL PODER DE TU GLORIA",
    text: "Espíritu de santo Dios ven a este presente hoy revélanos la gloria de tu reino Con poder de tu gloria cúbrenos vida nueva fluirá en ti la verdad de tu reino muéstranos con el poder de tu gloria con el poder de tu gloria cúbrenos.",
    tonalidad: "Dm",
    tiempo: 0,
    status: 1,
  ),
  Song(
    title: "ESCUCHARTE HABLAR",
    text: "Quiero escuchar tu dulce voz Rompiendo el silencio en mí ser Sé que me haría estremecer Me haría llorar o reír Y caería rendido ante ti Y no podría estar ante ti Escuchándote hablar Sin llorar como un niño Y pasaría el tiempo así Sin querer nada más Nada más que escucharte hablar",
    tonalidad: "G",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "ESTÁ CAYENDO",
    text: "Algo cayendo aquí es tan fuerte sobre mí Mis manos levantaré y su Gloria tocaré Está cayendo, su Gloria sobre mí Sanando heridas, levantando al caído Su Gloria está aquí Su Gloria está aquí Su Gloria está aquí.",
    tonalidad: "G",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "FAZ CHOVER",
    text: "Así como el ciervo anhela el agua Como tierra seca necesita la lluvia Mi corazón tiene sed de ti mi Dios y mi rey Haz llover, señor Jesús Derrama lluvia en este lugar Ven con tu río, señor Jesús Inundando mi corazón",
    tonalidad: "Bm",
    tiempo: 0,
    status: 1,
  ),
  Song(
    title: "FUENTE DE VIDA",
    text: "En Ti está todo, de Ti fluye vida A Ti puedo correr, a Ti puedo clamar Tus brazos de aliento son mi sustento Si Tú estás conmigo, ¿quién contra mí? Vuelvo mis ojos a la fuente Donde está la Vida Eterna, Jesucristo Eres Salvador, Hijo de Dios, Sanas mis heridas, me liberas con Tu amor, Eres Salvador, Hijo de Dios, Sanas mis heridas, me liberas del temor",
    tonalidad: "Dm",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "GLORIA",
    text: "queremos darte gloria, y alabanza levantamos nuestras manos, adorándote señor grande eres tú grande tus milagros son no hay otro como tú no hay otro como tú no hay otro como tú mereces la gloria, y la honra levantámos nuestras manos, exaltándote señor altísimo, milagroso salvador, no hay nadie como tú no hay nadie como tú altísimo, milagroso salvador, no hay nadie como tú no hay nadie como tú",
    tonalidad: "D",
    tiempo: 0,
     
    status: 1,
  ),
  Song(
    title: "GRACIAS",
    text: "Me has tomado en tus brazos y me has dado salvación De tu amor has derramado en mi corazón No sabré agradecerte lo que has hecho por mí Solo puedo darte ahora mi canción Yo te doy gracias Gracias Señor Gracias mi Señor Jesús Gracias, muchas gracias Señor Gracias mi Señor Jesús En la cruz diste tu vida Entregaste todo ahí Vida eterna regalaste al morir Por tu sangre tengo entrada Ante el trono celestial Puedo entrar confiadamente ante ti",
    tonalidad: "F#m",
    tiempo: 0,
      
    status: 2,
  ),
  Song(
    title: "GRANDES COSAS",
    text: "Tú eres el Dios de esta tierra eres el rey de este pueblo Jesús, Señor de naciones, Tú eres Tú eres la luz de este mundo esperanza para los perdidos Tú das la paz al cansado, Tú eres Nadie es como nuestro Dios nadie es como nuestro rey Grandes cosas va a ocurrir grandes cosas va a acontecer este lugar Grandes cosas va a ocurrir grandes cosas va a acontecer aquí",
    tonalidad: "Am",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "HAY PODER - NO DARÉ",
    text: "Hay poder en la sangre de Jesús hay poder sobre todo majestad solo tienes que creer y abrir tu corazón Hay poder en la sangre de Jesús No daré mi vida a nadie más que a Él No daré mi vida a nadie más que a Él No daré mi vida a nadie más No daré mi vida a nadie más porque solo Tú la puedes sostener",
    tonalidad: "D",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "HAZ LLOVER",
    text: "Haz llover, sobre este lugar, sediento estoy de Ti. Ven y sacia hoy la sed que hay en mí, lléname de Ti, ven que necesito que refresques mi interior. Ven que quiero más de Ti, hazme rebosar mi copa hasta sentir Tu presencia estremeciendo mi interior, ven y tócame, y abrázame, envuélveme en Ti Señor. Tu lluvia está cayendo, Tu gloria descendiendo, Tu fuego está ardiendo en mí. Tu lluvia está sanando, Tu gloria restaurando, Tu fuego está hoy sobre mí. Lluvia cae hoy sobre mí.",
    tonalidad: "Am",
    tiempo: 0,
      
    status: 2,
  ),
  Song(
    title: "HE DECIDIDO",
    text: "He decidido seguir a Cristo he decidido seguir a Cristo he decidido seguir a Cristo no vuelvo atrás, no vuelvo atrás Si otros vuelven, yo sigo a Cristo si otros vuelven, yo sigo a Cristo no vuelvo atrás, no vuelvo atrás La cruz delante y el mundo atrás la cruz delante y el mundo atrás no vuelvo atrás, no vuelvo atrás",
    tonalidad: "D",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "HERMOSO ERES",
    text: "En mi corazón hay una canción que demuestra mi pasión para mi Rey y mi Señor para Aquél que me amó Hermoso eres, mi Señor Hermoso eres Tú, Amado mío Tú eres la fuente de mi vida y el anhelo de mi corazón",
    tonalidad: "A",
    tiempo: 0,
      
    status: 2,
  ),
  Song(
    title: "LA BONDAD DE DIOS",
    text: "Te amo Dios, Tu amor nunca me falla Mi existir en Tus manos está Desde el momento que despierto hasta el anochecer Yo cantaré de la bondad de Dios En mi vida has sido bueno En mi vida has sido tan, tan fiel Con mi ser, con cada aliento Yo cantaré de la bondad de Dios Amo Tu voz, me has guiado por el fuego Tú cerca estás en la oscuridad Te conozco como Padre y como amigo fiel Mi vida está en la bondad de Dios Tu fidelidad sigue persiguiéndome Tu fidelidad sigue persiguiéndome Todo lo que soy te lo entrego hoy A Ti me rendiré Tu fidelidad sigue persiguiéndome",
    tonalidad: "G",
    tiempo: 0,
      
    status: 2,
  ),
  Song(
    title: "LA NIÑA DE TUS OJOS",
    text: "Me viste a mí, cuando nadie me vio Me amaste a mí, cuando nadie me amó Me viste a mí, cuando nadie me vio Me amaste a mí, cuando nadie me amó Y me diste nombre Yo soy tu niña La niña de tus ojos Porque me amaste a mí Y me diste nombre Yo soy tu niña La niña de tus ojos Porque me amaste a mí Me amaste a mí Me amaste a mí Me amaste a mí Me amaste a mí, Te amo más que a mi vida Te amo más que a mi vida Te amo más que a mi vida, más",
    tonalidad: "C",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "LA ULTIMA PALABRA",
    text: "Dame de tu eterna paz Dame el don para esperar Ayúdame a confiar en Ti porque mis fuerzas no puedo más Tú eres mi sustento Tú mi creador Y la última palabra la tienes Tú",
    tonalidad: "D",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "LIBRE",
    text: "Donde el Espíritu de Dios está hay libertad, puedo adorar Todas mis culpas y maldades fueron borradas en la cruz, libre soy. Perdonado soy solo por tu amor no hay más condenación Cristo me libertó. Caen las murallas caen las cadenas Dios destruyó libre soy Libre Dios me hizo libre Él venció la muerte por mí libre soy, libre soy. Se rompen cadenas no soy esclavo más en Cristo soy libre no hay más condenación",
    tonalidad: "Am",
    tiempo: 0,
      
    status: 2,
  ),
  Song(
    title: "LLEVAME A TUS ATRIOS",
    text: "Señor llévame a Tus Atrios Al Lugar Santo Al Altar de Bronce Señor Tu Rostro quiero ver Pásame en la muchedumbre Por donde el sacerdote canta Tengo hambre y sed de justicia Y solo encuentro un lugar Llévame al lugar Santisimo Por la Sangre del Cordero Redentor Llévame al lugar Santisimo Tocame, limpiame, heme aqui!",
    tonalidad: "Em",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "LIBRE SOY",
    text: "libre soy por la sangre de jesús todo mis pecados mi pasado el perdono ya no habrá en mi mas el temor con su amor me perdono se rompen las cadenas se rompen las cadenas se rompen las cadenas libre soy",
    tonalidad: "Dm",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "ME DISTE TODO",
    text: "Miro a tus ojos veo tu amor, miro a tus manos veo mi perdón. Miro a la cruz, me veo en Tu rostro, lo que anhelo eres tú. Tu esperanza me alcanzó, me sanaste con tu amor. Abriste la puerta de tu corazón, me diste la vida, me diste perdón.",
    tonalidad: "Dm",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "NADIE COMO TÚ",
    text: "Me cautiva tu amor, solo quiero quedarme aquí a tus pies. Mi refugio eres tú, mi escondite es tú presencia. Solo quiero ver tu rostro y contemplarte, y contemplarte. Tienes toda mi atención, vengo a adorarte, vengo a adorarte. Nadie como tú, nadie como tú. Grande y poderoso, mi padre amoroso. Nadie como tú, nadie como tú. Fiel y verdadero, el que venció en el madero. Jesús Jesús",
    tonalidad: "A",
    tiempo: 0,
      
    status: 2,
  ),
  Song(
    title: "NO BASTA",
    text: "No basta solo con cantar, no basta solo con decir. No es suficiente solo con querer hacer, es necesario morir. No basta solo con soñar, no basta solo con pedir. No es suficiente solo con querer hacer, es necesario morir. Dame tu vida, esa clase de vida que sabes dar. Dame tu vida, yo quiero vivir solo para ti. Dame tu vida, resucítame en ti. Yo quiero vivir solo para ti.",
    tonalidad: "G",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "NO HAY LUGAR MÁS ALTO",
    text: "A tus pies arde mi corazón A tus pies entrego lo que soy Ese lugar de mi seguridad Donde nadie me puede señalar Me perdonaste, me acercaste a tu presencia Me levantaste, hoy me postro a adorarte No hay lugar más alto, más grande Que estar a tus pies, que estar a tus pies Y aquí permaneceré, postrado a tus pies Y aquí permaneceré a los pies de Cristo",
    tonalidad: "A",
    tiempo: 0,
      
    status: 2,
  ),
  Song(
    title: "NO HAY NADIE COMO TÚ",
    text: "No hay nadie como Tú, no hay nadie como Tú, precioso y glorioso, tan bello y tan hermoso Jesús, Jesús, precioso Jesús. Yo te amo, yo te adoro",
    tonalidad: "G",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "OCÉANOS",
    text: "Tu voz me llama a las aguas donde mis pies pueden fallar, y allí te encuentro en lo incierto; caminaré sobre el mar y a Tu nombre clamaré, en Ti mis ojos fijaré, en tempestad descansaré en Tu poder, pues Tuyo soy hasta el final; Tu gracia abunda en la tormenta, Tu mano, Dios, me guiará, cuando hay temor en mi camino, Tú eres fiel y no cambiarás; que Tu Espíritu me guíe sin fronteras, más allá de las barreras, a donde Tú me llames, Tú me llevas más allá de lo soñado, donde puedo estar confiado al estar en Tu presencia.",
    tonalidad: "Bm",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "PERDÓN",
    text: "Perdón Jesús, perdón, perdóname Señor. Yo sé que débil fui, te herí y te lastimé. Perdóname Señor. Mas hoy en tu misericordia quiero descansar, sé que tu sangre me puede limpiar. Con arrepentimiento en mi corazón, me humillo y te pido perdón.",
    tonalidad: "D",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "PRECIOSA SANGRE",
    text: "Preciosa sangre se derramó, preciosa sangre fluyó por amor. Sobre ti el dolor, tus venas lloraron. Jesús, Jesús, Jesús. Hay poder en la sangre que fluyó por amor. Hay poder en la sangre que Él derramó. Preciosa sangre me purificó, preciosa sangre que me transformó. Sobre ti el dolor, tus venas lloraron. Jesús, Jesús, Jesús. Instrumental: Bm-A-F#m-C#m. Tu sangre me transformó, tu sangre me perdonó. Tu sangre me limpió, tu sangre me sanó. Tu sangre me sanó.",
    tonalidad: "Bm",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "QUE SERÍA DE MI",
    text: "¿Qué sería de mí si no me hubieras alcanzado? ¿Dónde estaría hoy si no me hubieras perdonado? Tendría un vacío en mi corazón Vagaría sin rumbo, sin dirección Si no fuera por tu gracia y por tu amor Si no fuera por tu gracia y por tu amor Sería como un pájaro herido que se muere en el suelo Sería como un ciervo que brama por agua en un desierto Si no fuera por tu gracia y por tu amor Si no fuera por tu gracia y por tu amor",
    tonalidad: "G",
    tiempo: 0,
      
    status: 2,
  ),
  Song(
    title: "RENUÉVAME",
    text: "Renuévame Señor Jesús ya no quiero ser igual Renuévame Señor Jesús pon en mí tu corazón Porque todo lo que hay dentro de mi necesita ser cambiado señor Porque todo lo que hay dentro de mi corazón necesita más de ti",
    tonalidad: "D",
    tiempo: 0,
    status: 1,
  ),
  Song(
    title: "RESTAURARÉ",
    text: "Levantaré hoy el fundamento las calzadas restauraré, levantaré muchas generaciones y su tierra sanaré dice el señor. Restauraré lo que comió la oruga lo que la langosta destruyó levantaré muchas generaciones y su tierra sanaré dice el señor.",
    tonalidad: "Dm",
    tiempo: 0,
    status: 1,
  ),
  Song(
    title: "SANTO POR SIEMPRE",
    text: "Mil generaciones Se postran a adorarle Le cantan al Cordero que venció Los que nos precedieron y los que en Él creerán Le cantarán a Aquel que ya venció Tu nombre es más alto Tu nombre es más grande Tu nombre sobre todo es Sean tronos, dominios, poderes, potestades Tu nombre sobre todo es Cantan ángeles, Santo Clama la creación, Santo Exaltado Dios, Santo Santo por siempre Si te ha perdonado y tienes salvación Cántale al Cordero que venció Si te ha libertado, Su nombre ha puesto en Ti Cántale al Cordero que venció Cantaremos siempre ¡Amén! Canta el pueblo al Rey, Santo Soberano es Él, Santo Y por siempre es, Santo Santo por siempre",
    tonalidad: "G",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "TEMPRANO YO TE BUSCARÉ",
    text: "Temprano yo te buscaré de madrugada yo me acercaré a Ti mi alma te anhela y tiene sed para ver Tu gloria y Tu poder. Mi socorro has sido Tú en la sombra de tus alas yo me go zaré mi alma está apegada a Ti porque Tu diestra me ha sostenido oh, Tu diestra me ha sostenido.",
    tonalidad: "G",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "TU NOMBRE ES SANTO",
    text: "Yo entro al lugar más santo a través del Cordero de Dios y entro tan solo a adorarte, yo vengo a honrar al Yo Soy. Dios te adoro a ti, te adoro a ti. Pues tu nombre es santo, santo, oh Dios.",
    tonalidad: "Em",
    tiempo: 0,  
    status: 1,
  ),
  Song(
    title: "TUS CUERDAS DE AMOR",
    text: "Aunque pase el tiempo sé que tu promesa cumplirás, nada en ti se perderá, esa es mi seguridad. Tus cuerdas de amor cayeron sobre mí. Es tu amor que me sostiene, el que me levanta, el que me da paz, me da seguridad de lo que vendrá, Tú tienes el control, nunca pierdes el control. Escucho el eco de tu voz resonando en mi interior, tus palabras me sostendrán, esa es mi seguridad. Los velos están cayendo hoy y puedo ver con claridad, mi fe se está encendiendo hoy y hoy me vuelvo a levantar.",
    tonalidad: "Bm",
    tiempo: 0,
    status: 2,
  ),
  Song(
    title: "UNCIÓN EN EL AIRE",
    text: "Yo no sé qué tenía Daniel que cuando oraba leones callaban, yo no sé qué tenía Elías que profetizaba y fuego caía, yo no sé qué tenía Moisés que al bajar del monte él resplandecía, yo no sé qué tenía Samuel que la voz del padre él reconocía. Pero hay una unción en el aire y lo que me cueste quiero entregarte, hoy derramarás tu espíritu y tus hijos profetizarán. ¡Yo veo señales, yo veo milagros, yo veo tinieblas hoy retroceder! Y ese poder está sobre mí. Esa unción llegó, la puedo sentir y ese poder está sobre mí. El fuego llegó, me consumió, no soy el mismo.",
    tonalidad: "Cm",
    tiempo: 0,
    status: 1,
  ),
  Song(
    title: "VEN ESPÍRITU VEN",
    text: "Ven Espíritu ven, y lléname Señor con tu preciosa unción. Purifícame y lávame, renuévame, restáurame, Señor, con tu poder. Purifícame y lávame, renuévame, restáurame, Señor, te quiero conocer.",
    tonalidad: "D",
    tiempo: 0,
      
    status: 1,
  ),
  Song(
    title: "VINE ALABAR",
    text: "vine a alabar a dios, vine a alabar a dios, vine a alabar su nombre. vine a alabar a dios. el vino a mi vida en un día muy especial, cambió mi corazón por un nuevo corazón y esa es la razón por la que digo que vine a alabar a dios. vine a alabar a dios.",
    tonalidad: "D",
    tiempo: 0,   
    status: 1,
  ),
  Song(
    title: "YO NAVEGARÉ",
    text: "Yo navegaré, en el océano del espíritu y allí adoraré, al Dios de mi amor. Yo adoraré al Dios de mi vida y allí adoraré al Dios que me amó. Espíritu, espíritu, desciende como fuego, como en Pentecostés, y lléname de gozo. Lléname, lléname, con tu presencia lléname, lléname, con tu poder lléname, lléname, con tu amor. Espíritu de Dios, llena mi vida, llena mi alma, llena mi ser.",
    tonalidad: "Am",
    tiempo: 0,
    status: 1,
  ),
];

//ALABANZAS
final List<Song> cancionesCompletas1 = [
  Song(
    title: "AGUAS PROFUNDAS",
    text: """
CANCIÓN: Aguas Profundas - Marcos Brunet
TONALIDAD: Am
TIEMPO: 166bpm

INTRO : *GUITARRA*
// Am   F     G    Em G
   Oh   oh    oh
   Am   F     G
   Oh   oh    oh//

Am          F         G     Em G
//Ven sobre mi como lluvia
Am                  F
  Has tus aguas subir 
             G  ( Em - G )
  en este lugar
Am            F         G   Em G
  Libera tu rio sin medida
Am         F         G
  Y ven a tus aguas agitar//

CORO
            Am              F   
yo quiero nadar, yo quiero nadar 
       G  ( Em - G )
en tu rio
            Am              F    
yo quiero beber, yo quiero beber 
          G   ( Em - G )
de tus aguas

PUENTE
Dm        F              G    G4 G
  Existen aguas a los tobillos
Dm        F              G
  Existen aguas a las rodillas
Dm        F             G   G4 G
  Existen aguas  a los lomos
Dm                   F         G
  Pero hay aguas profundas yo sé..

INSTRUMENTAL: Am - F - G
""",
    tonalidad: "Am",
    tiempo: 166,
    multitrackLink: "https://youtu.be/v3aE5tqNwQo",  
    youtubeLink: "https://youtu.be/IN2nC_Wm5Fc?si=C-ItDqpf01IExRaj",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/-WHPKKvdSYE",
      "https://youtu.be/j3Eh6JXj8so",
      "https://youtu.be/DYDY4tdv7Ig?si=q3NX3FLMSmwpo2VX",
      "https://youtu.be/B62PfHNyzis?si=Pc-eWMT0Wugnb1Kx",
      "https://youtu.be/e6lW15qW2s8?si=10PGIJOue_Vyx8uu",
    ],
    pianoLink: [
      "https://youtu.be/xa1gwdrPch8",
      "https://youtu.be/f-UCsUJftuw",
      "https://youtu.be/AHmzZOysM5U?si=WlwUKgRX9bh3TWlP",
      "https://youtu.be/XBzDcPnC9I0?si=_9B0RCEeKpPkVywD",
    ],
    bassLink: [
      "https://youtu.be/u80eMNc1cPQ",
      "https://youtu.be/lqjMWX9d7ws",
      "https://youtu.be/3Log8d0aYgs?si=GNDTrS2VVTzOgZq7",
      "https://youtu.be/u196UTSomKg?si=v8FmFV_Wtw0cyNvD",
    ],
    drumsLink: [
      "https://youtu.be/DF1G3efiRAI",
      "https://youtu.be/ojswfyHWzco",
      "https://youtu.be/tUmzGo4aaRk?si=I1ZeMbUAJwzASF0W",
      "https://youtu.be/HAM8VzMOpfo?si=1ldhDx4Lpt6cfB6V",
    ] 
  ),
  Song(
    title: "ALABA",
    text: """
CANCIÓN: Alaba (Praise - Elevation Worship)
TONALIDAD: A
TIEMPO: 127bpm

INTRO: A

Que toda la
Creación
Alabe a Dios
Alabe a Dios

VERSO 1
     A               
Te alabo en el valle

Te alabo en el monte
     E             D9          
Te alabo en el día
                A
Te alabo en la noche
Te alabo en el medio
   A/D      A
Estando rodeado
     E 
Porque cuando alabo 
D9                A
   Tú estás a mi lado

PRE-CORO
      E   
Mientras tenga aliento
 D9
Mi alma canta y

CORO
F#m D       A
A__laba a Dios
        E
Mi corazón
F#m D       A
A__laba a Dios
        E
Mi corazón

VERSO 2
     A
Te alabo al sentirlo
   A/D        A
Y aun cuando no
     E        D9
Te alabo y sé
                  A
Que estás en control
Es más que un sonido
   A/D    A         
Es adoración 
    E
Y cuando alabamos
D9            A
   Caerá Jericó

PRE-CORO
      E   
Mientras tenga aliento
 D9
Mi alma canta y

CORO 1
F#m D       A
A__laba a Dios
        E
Mi corazón
F#m D       A
A__laba a Dios
        E
Mi corazón

CORO 2
F#m
No me detengo
     D
Mi Dios vivo estas
 A                E 
Como me voy a callar

PUENTE 1
  A
Alabo al que reina
Alabo al Señor
Alabo a aquel que la tumba venció
Alabo al que es bueno
Alabo al que es fiel
Le alabo porque no hay otro como él

PUENTE 2
 A
Alabo al que reina
 Bm
Alabo al Señor
 F#m                 D
Alabo a aquel que la tumba venció
  A
Alabo al que es bueno
  Bm
Alabo al que es fiel
    F#m               D
Le alabo porque no hay otro como él

[CORO 1 Y 2]

FINAL: // F#m D  A  E //        
Que toda la
Creación
Alabe a Dios
Alabe a Dios
""",
    tonalidad: "A",
    tiempo: 127,
    multitrackLink: "https://youtu.be/Ype4tZgWjPY",  
    youtubeLink: "https://youtu.be/0WOs_Fg5tHE?si=ILYxUv0tUmsrK78Y",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/4uPUO2QY5ik?si=RZ3MfWZp22_YcvZA",
    ],
    guitarLink: [
      "https://youtu.be/Q1Cm6lP0Kos",
      "https://youtu.be/akoTZRYmoOE",
      "https://youtu.be/qoUZw5vc08Q?si=nBEW6arBvybm1UFi",
      "https://youtu.be/9RljgAzOkQk?si=bY5B9cCStpKpZpVM",
      "https://youtu.be/_Hj5IKNy2j4?si=hDcc5mQ137ZPnQ0E",
    ],
    pianoLink: [
      "https://youtu.be/sGY2XEzhprM",
      "https://youtu.be/extFeMzt3GM",
      "https://youtu.be/HXgb0N2O1KA?si=LdTvIHDyhTqzBxki",
      "https://youtu.be/9nVZkR9cC6Y?si=SDNeN5luHzrbVA1H",
    ],
    bassLink: [
      "https://youtu.be/3HZ9gZcnHDs?si=tF_lyqdAawoaupye",
      "https://youtu.be/dYqo-s0UP_s?si=4n2grhZddn7yTko9",
      "https://youtu.be/ZtW-vPjoR2I?si=M3SUujo9PdInn-YU",
    ],
    drumsLink: [
      "https://youtu.be/tYjQSPGOFd8",
      "https://youtu.be/inHgB4vNchU",
      "https://youtu.be/IWkduRHKQKA?si=OSdAtSfz-AAox5Ls",
      "https://youtu.be/X6qziNPrTg0?si=o6MP4uWQemifv-Yo",
    ] 
  ),
  Song(
    title: "ANTE TI CON GOZO",
    text: """
CANCIÓN: Ante ti con gozo - MSM
TONALIDAD: Bm(Original Am)
TIEMPO: 150bpm

INTRO: // G - D // Em - F#7
     Bm              Em
  Me gozaré en tu presencia Jehová
         F#sus                F#7
  con todas mis fuerzas gritaré, hey!
     Bm              Em
  Me gozaré en tu presencia Jehová
        Bm       F#7         Bm
  con todas mis fuerzas gritaré.

CORO:
       G       D    G     D
//Ante ti con gozo palmiaré
        G     D     G      D
  con alegre danza celebraré
       Em           F#7  
  saltare y me gozare//
""",
    tonalidad: "Bm",
    tiempo: 150,
    instrument: 0,
  ),
  Song(
    title: "BUENO ES ALABAR",
    text: """
CANCIÓN: Bueno es alabar - Danilo Montero
TONALIDAD: G
TIEMPO: 119bpm

INTRO: // G C D - C D // Em D
 G           C       D     C     D
Bueno es alabarte Señor ¡Tu nombre!
 G            C         D  
Darte gloria honra y honor 
      C   D
¡Por siempre!
 G           C       D
Bueno es alabarte señor
    Em             D
Y gozarme en tu poder//

CORO:
         G    C     D    C  D
Porque grande eres tú
  G      C      D        C  D
Grandes son tus obras   
         G    C     D
Porque grande eres tú
               Em  
Grande es tu amor 
               D
grande son tus obras//
""",
    tonalidad: "G",
    tiempo: 119,
    multitrackLink: "https://youtu.be/LJPYEXDzw3M?si=We_Q8zlZDPZMUzLS",  
    youtubeLink: "https://youtu.be/3hamkWaA2lM?si=73e0okKJC0ww0_OG",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/FSe1IUM57vY",
    ],
    guitarLink: [
      "https://youtu.be/3DAliiOpFzg",
      "https://youtu.be/3DAliiOpFzg",
      "https://youtu.be/sKpTWNMUSjA",
    ],
    pianoLink: [
      "https://youtu.be/kGdaaNv6UR8",
    ],
    bassLink: [
      "https://youtu.be/WmuUFQO2svc",
      "https://youtu.be/Y7iIXdbyqW0",
    ],
    drumsLink: [
      "https://youtu.be/ub0yqf5BkK8",
      "https://youtu.be/RSItrqHsDkc",
    ] 
  ),
  Song(
    title: "CAMBIARÉ MI TRISTEZA",
    text: """
CANCIÓN: Cambiaré mi tristeza - Vertical
TONALIDAD: A
TIEMPO: 120bpm

INTRO: *bajo una vez y despues todos* 
        // A - D - F#m - E //
CORO:
A        D       F#m E
  Cambiare mi tristeza,
A        D        F#m E
  Cambiare mi vergüenza
A      D               F#m      E    
 Los entregare, por el gozo de Dios
A  D  F#m E 

A        D      F#m E       
  Cambiare mi dolor.......           
A         D   F#m E
  y mi enfermedad
A             D         F#m E                              
  Los entregare por el gozo de Dios
A D F#m E
PUENTE:
   A     D               
 //Si señor
     F#m    E
  Si, Si Señor//

ESTROFA:
    A           D     
 Estando atribulado, 
       F#m       E
 pero nunca derrotado
A          D      F#m E             
  Y perseguido este hoy
       A             D
Maldiciones no me  afectan
        F#m          E
 Pues yo sé a quien voy
       A      D    F#m E 
En su gozo, fuerte soy
PRE-CORO:
E
  Aunque triste en la noche yo esté
       G           D
Gozo viene en la mañana
""",
    tonalidad: "A",
    tiempo: 120,
    multitrackLink: "https://youtu.be/tnzBtRvIxKA?si=tRJ_o1uUzo5pnZ9O",  
    youtubeLink: "https://youtu.be/046GEu8p31k",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/046GEu8p31k",
      "https://youtu.be/8mcWXztpejg",
    ],
    guitarLink: [
      "https://youtu.be/3-ekqzZypFA",
      "https://youtu.be/3-ekqzZypFA",
      "https://youtu.be/_1Qz1-Lh_zk?si=vqw0GtBCWThR76pA",
      "https://youtu.be/otbnLc7gWdg?si=Mw_JXzQu1Ii87cEc",
    ],
    pianoLink: [
      "https://youtu.be/jbqrQrq8rVE",
      "https://youtu.be/yd9IFuDQXSA",
    ],
    bassLink: [
      "https://youtu.be/P9oBaFm7-BE",
    ],
    drumsLink: [
      "https://youtu.be/P9oBaFm7-BE",
      "https://youtu.be/pN8t7uZfZKQ",
      "https://youtu.be/MDq_gyo-QU4",
      "https://youtu.be/MDq_gyo-QU4",
    ] 
  ),
  Song(
    title: "CON MI DIOS",
    text: """
CANCIÓN: Con mi Dios - JAR
TONALIDAD: Em
TIEMPO: 155bpm

INTRO: /// Em D Em C D ///    
 Em              D          Em    C D    
¡Con mi Dios yo saltaré los muros
Em            D              Em
con mi Dios ejércitos derribaré!

CORO
G                  D   
  El adiestra mis manos 
           Em
  para la batalla,
D                                    
  puedo tomar con mis manos 
            Em 
el arco de bronce,
D              G
Él es escudo, la roca mía,
D                      G
Él es la fuerza de mi salvación,
   B7                Em  
mi alto refugio, mi fortaleza,
Am   B7             Em  
Él   es, mi libertador.
""",
    tonalidad: "Em",
    tiempo: 155,
    multitrackLink: "https://youtu.be/twZtfPScX8k",  
    youtubeLink: "https://youtu.be/OtrIz0gC5CM",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/0U1ywQV7J2w",
      "https://youtu.be/gZ_n_rmlT0w",
      "https://youtu.be/hVW2WF9YMN8?si=GJyAfyyVACGNmOQs",
      "https://youtu.be/Nv0wWd96AIQ?si=bvtvI52hPbNQPMZz",
      "https://youtu.be/jlSfm1HBpqQ?si=qaDAmoph8F1F_N7X",
    ],
    pianoLink: [
      "https://youtu.be/SzFaMXS-FrU",
      "https://youtu.be/3xJH7hBTKig",
      "https://youtu.be/K8KBxx8vIbQ",
    ],
    bassLink: [
      "https://youtu.be/lpLFfHnwpms",
      "https://youtu.be/f9XbF8zsFDE",
      "https://youtu.be/OtrIz0gC5CM",
    ],
    drumsLink: [
      "https://youtu.be/529fXYfyEWA",
      "https://youtu.be/7G5UVa-6YTo",
      "https://youtu.be/nopGia6jWCQ",
    ] 
  ),
  Song(
    title: "DANZANDO",
    text: """
CANCIÓN: Danzando - Gateway Worship
TONALIDAD: Bm
TIEMPO: 95bpm

INTRO: // Bm - G - D - A //

VERSO 1:
           Bm  G
Tu palabra dice  aunque 
D            A         Bm       G
pase por el fuego no me quemare
      D           A      
Y si paso por las aguas, 
       Bm      G
no me ahogaré 
        D          A    
Aunque haya oscuridad, 
    Bm     G
con fe, caminaré
        D              A
Pues tú siempre vas conmigo

           Bm    G
Tu palabra dice
        D              A         Bm  
No hay justo que Tú hayas desamparado
G        D                A    
   Eres pan para el hambriento 
        Bm    G
y necesitado
       D           A          Bm    G
En mi mesa nunca, nunca ha faltado
        D               A
Tú provees y no has fallado

PRE-CORO:
G         F#7
Yo no temeré
      G        F#7
Tu promesa es fiel

CORO:
   Bm       G        D          A
Tu yugo es fácil, ligera es Tu carga
      Bm       G      D     A
Te entrego mi vida y mi alabanza
     Bm         G         D     A
Mi escudo, mi fuerza, mi seguridad
      G               F#7
Con Cristo camino y estoy
                           Bm G D
Danzando en cada temporada
    A                      Bm G D A
Danzando en cada temporada

VERSO 2:
           Bm    G
Tu palabra dice
       D         A               Bm  
Que Tú oyes el clamor del quebrantado
G             D           A    
   Por Tu llaga en la cruz, 
         Bm     G
fuimos sanados
       D           A            Bm  G
Sobre toda enfermedad, Tú has ganado
      D                 A
Y mi vida está en Tu mano

           Bm    G
Tu palabra dice
        D             A    
Que Tu muerte en la cruz 
           Bm    G
fue por salvarnos
        D       A            Bm    G
Que perdonas y redimes del pecado
          D        A          Bm    G
Y en las nubes, seremos arrebatados
      D           A
Cara a cara, Te veremos
*vuelve al pre-coro*

PUENTE:
Sigo danzando, glorificando
En cada temporada, Tú sigues obrando
Aunque ande en el valle de sombra
Danzo, danzo, danzo, danzo
Bm                   G
// No se apaga, no se apagará este ritmo
D                     A
  Aunque venga contra mí el enemigo
Bm                       G
   Tus promesas siempre van conmigo
D              A
Danzo, danzo, danzo, danzo //
Bm               G
En Ti yo confío, en Ti yo confío
D                A
En Ti yo confío, en Ti yo confío
Bm               G              D  A
En Ti yo confío, en Ti yo confío
*vuelve al coro*
""",
    tonalidad: "Bm",
    tiempo: 95,
    multitrackLink: "https://youtu.be/nSsZ3mLQvHA",  
    youtubeLink: "https://youtu.be/AQtjmET3DTc",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/-quy_JtwLB0",
      "https://youtu.be/McyJ_nwz_fk",
      "https://youtu.be/I71OYw_-8cc",
      "https://youtu.be/PhHkt25dRY4",
    ],
    guitarLink: [
      "https://youtu.be/1d3lKUA6KK0",
      "https://youtu.be/XeKFZO_uooI",
      "https://youtu.be/_y8J4VGZhyg?si=RTAWhZEQsPLpWlKx",
      "https://youtu.be/tN7L34n3qGA",
    ],
    pianoLink: [
      "https://youtu.be/aaJEuGfYjFs",
      "https://youtu.be/-zvWhIykhe4",
      "https://youtu.be/l9uozO3jTeU",
      "https://youtu.be/nqLMr7qXhvs",
    ],
    bassLink: [
      "https://youtu.be/T-Shsp21jmU",
      "https://youtu.be/s-a9n_Q5Z4Q?si=WCekkEboWF9JjeQ9",
    ],
    drumsLink: [
      "https://youtu.be/bujgZ-DkU68",
      "https://youtu.be/qKvfkltsvos",
      "https://youtu.be/HfotXql4P9E",
      "https://youtu.be/nSsZ3mLQvHA",
    ] 
  ),
  Song(
    title: "DESPIERTA",
    text: """
CANCIÓN: Despierta - Su presencia
TONALIDAD: Dm
TIEMPO: 90bpm

INTRO: *solo guitarra : 
Dm - Bb - F - C (con cejilla)*
F                     C
Como en el pasado volverán
             Dm                 Bb
Los que rescataste a ti regresarán
 F                      C
Llenos de alegría cantarán
                 Dm            Bb
El llanto y el dolor desaparecerán

PRE-CORO:
        Dm        Bb
Por eso yo no temeré
           F              C
Lo que el hombre pueda hacer
         Dm            Bb
Yo confiaré en mi hacedor
          F                 C
que extendió el cielo y el mar

CORO:
    Dm
Despierta, Señor
                   Bb
Despiértate con tu fuerza
                 F
con tu brazo poderoso
                    C
Como en el tiempo antiguo
       Dm
Con tu soplo secaste el mar
               Bb
e hiciste un camino
                  F
Tú rompiste mi pasado
                     C
La libertad es mi destino

PUENTE:
Dm
oh, oh, oh, oh, oh
Bb
  Sé que todo lo puedes
F
oh, oh, oh, oh, oh
C
Nada puede detenerte
""",
    tonalidad: "Dm",
    tiempo: 90,
    youtubeLink: "https://youtu.be/1hU-u2NbRnM",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/lk0SNTZ_RM8?si=iYUJynipkETDaRGl",
    ],
    pianoLink: [
      "https://youtu.be/LCgh2Pl6qYU",
      "https://youtu.be/r8WuRQ2IANw",
      "https://youtu.be/ZuaaipIz180",
    ],
    drumsLink: [
      "https://youtu.be/5OyjkWytuZk",
    ] 
  ),
  Song(
    title: "DIOS NO ESTÁ MUERTO",
    text: """
CANCIÓN: GOD'S NOT DEAD - Newsboys
TONALIDAD: G#m
TIEMPO: 130bpm

INTRO: G#m7 - F#7 - Bsus2 - Esus2
VERSO 1:
G#m          F#7          Bsus2
    Que tu amor descienda con poder
C#m          G#m             
      Revolución, que traiga 
     Esus2
avivamiento en todo lugar
*vuelve al intro una vez*

PRE-CORO:
F#7                   G#m
    Solo en ti yo soy libre
F#7               Esus2
   Y a este mundo venceré

CORO:
(Mi Dios no está muerto, 
 el vivo está)
G#m
Él venció la muerte
Y vive para siempre
    F#7
Mi Dios no está muerto, el vivo está
Esus2
El venció la muerte
 Bsus2
Y vive para siempre
 G#m    F#7  Bsus2      Esus2
//Vive, vive, vive para siempre//

VERSO 2:
G#m            F#7           Bsus2
     Que las tinieblas huyan ante ti
C#m      G#m             Esus2              
     Avívame y dame fortaleza para seguir
*PRE-CORO y CORO*

PUENTE:
            Bsus2
//Desciende hoy
           F#7
Con fuego Dios
        G#m
La creación temblará
   C#m
Al oír tu voz//
""",
    tonalidad: "G#m",
    tiempo: 130,
    multitrackLink: "https://youtu.be/-1cHfGw2_aI",  
    youtubeLink: "https://youtu.be/NNiM9WfhAfg?si=SNJ5CAGv5dEu2VGb",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/2k6818XnzpE",
      "https://youtu.be/Z6JMNztqXio",
      "https://youtu.be/p8Oedf3YEs0",
      "https://youtu.be/i5rV1K0iR4U?si=dBj2FdFX7KL7TKqN",
    ],
    pianoLink: [
      "https://youtu.be/afTTYfd0FhY",
      "https://youtu.be/SxsIPest7LU",
      "https://youtu.be/yOU8L76ZpGw?si=CVFA6O7rRfTTR2E_",
      "https://youtu.be/zwEWyiSx9jo ",
    ],
    bassLink: [
      "https://youtu.be/uZvC6hlTcO8?si=vqxMkHILHFdhdg7L",
      "https://youtu.be/9kMg16FZU4w?si=wqTITxrmIs8cdWrA",
    ],
    drumsLink: [
      "https://youtu.be/qq76uK6ikmc",
      "https://youtu.be/YVFBQeiSCrc",
      "https://youtu.be/mbOVvF6KLIw?si=jIjZJ6IXB99ziK9j",
      "https://youtu.be/9qc8QIo3mtk?si=9TmRncoSowGkkkPc",
    ] 
  ),
  Song(
    title: "EL EJÉRCITO DE DIOS",
    text: """
CANCIÓN: El ejército de Dios -
Marco Barrientos
TONALIDAD: Em
TIEMPO: 144bpm

          Em                           
//Porque grande es el Señor  
        C         D        Em
y para siempre es su misericordia//

CORO:
       C                  D
//El ejercito de Dios marchando esta 
        C                 D
contra todo principado y potestad
     C              Am  D 
el ejercito de Dios       
            Em
marchando está//
""",
    tonalidad: "Em",
    tiempo: 144,
    multitrackLink: "https://youtu.be/4Nmw7xEE8KI",  
    youtubeLink: "https://youtu.be/1BEhrndJlrM",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/acLQETJpCF8",
      "https://youtu.be/6J4-W153hMM",
      "https://youtu.be/kGGaOcyH864?si=uxXIaue1i7ZBICfA",
      "https://youtu.be/T6Y4oNG6sWQ?si=Q0AvpwQ4p_JOaPVM",
    ],
    pianoLink: [
      "https://youtu.be/Crs6ceAAi-0",
      "https://youtu.be/Uae68abHm3c",
      "https://youtu.be/j8rrhSeI63A?si=ULbj3CADeIVn_LO8",
    ],
    bassLink: [
      "https://youtu.be/VnaDyaFFlt8",
      "https://youtu.be/ctfndUOlMuY",
      "https://youtube.com/shorts/0I9gr5VtpTc?si=HbQBy5ENQPHfscgj",
      "https://youtu.be/Jz2ZMyQzWWE?si=H-5FbVDElvqty9C5",
    ],
    drumsLink: [
      "https://youtu.be/ANu8uSLGxsg",
      "https://youtu.be/ceeexE2J5aQ",
      "https://youtu.be/Y6lmBTzZVFk?si=uD5uCcfuqmb2ml_o",
      "https://youtu.be/fa-_inUR3ZA?si=nT5r_3aL3vXE3dd2",
    ] 
  ),
  Song(
    title: "EL SEÑOR ES MI REY",
    text: """
CANCIÓN: El Señor es mi rey - MSM
TONALIDAD: Bm (Original Cm)
TIEMPO: 150bpm

Bm Bm Bm Bm A Bm (Intro)

               Bm        A
El Señor es mi rey, mi todo
Bm                Bm       A
   el Señor es mi luz, mi rey...

G                           D
  el que me hace vibrar de gozo
G                  D
  el que guía mis pasos
G                      D
  el que extiende sus brazos
G                    D  A  Bm   
  el creador de los cie_e_los...
""",
    tonalidad: "Bm",
    tiempo: 150,
    youtubeLink: "https://youtu.be/NFweJ-9tMaI?si=aACeo_EvOs2LuJJf",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/cJZktebrquk?si=ITdkGaHm4L6MU20M",
      "https://youtu.be/K9sMjagWW50?si=PHslO1nEC_5myOA1",
    ],
    pianoLink: [
      "https://youtu.be/C2IVmKceDsc?si=oA3UlMuTM7pM_O_U",
      "https://youtu.be/OBVg5VniKcA?si=ET7PT0EixMOtJn-P",
    ],
    bassLink: [
      "https://youtu.be/J9kkFSsyZi8?si=-bgsfSd91Vo3qK_Z",
    ],
    drumsLink: [
      "https://youtu.be/_LAWgUr04D0?si=XxbZ1APOLNDcSUnI",
      "https://youtu.be/njgbYuvqh4g?si=OAx28fiT7M3d8tjo",
    ] 
    
  ),
  Song(
    title: "EL SEÑOR MARCHANDO VA",
    text: """
CANCIÓN: El Señor marchando va - 
Unidos en alabanza
TONALIDAD: Bm
TIEMPO: 145bpm

INTRO:  /// Bm - A /// G - A - Bm
      Bm
El  señor  marchando  va
Y  su  pueblo  junto  a  él  esta
     G                      A
Su  gloria  en   nuestras  vidas
      Bm
Brillará
       Bm
Su  victoria  nos  ha  dado  ya
Y  su  brazo  nos  fortalecerá
      G             A           Bm
Lucharé hasta la  tierra conquistar

CORO:
      G                    D
En mi vida el capitán es Cristo
       G                   D
marcharemos ante en su presencia
       G             A         Bm
No hay nada que nos pueda derrotar
""",
    tonalidad: "Bm",
    tiempo: 145,
    youtubeLink: "https://youtu.be/Z5zAA4gfhZM",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/9x_pW2WytEo?si=jm9HthaBhlkRe1sX",
    ],
    bassLink: [
      "https://youtu.be/tGgGzxHb460?si=dkBUt03YOr1fi9LW",
      "https://youtu.be/RysrqwCk0Hg?si=S2T21Zc_eKPQ4Wox",
    ],
    drumsLink: [
      "https://youtu.be/o7jx4sTOsJY?si=eTUFLpGn_pNU9uA8",
      "https://youtu.be/pzX46EVHBYU?si=V2dSaTuUfkLpzfax",
    ] 
  ),
  Song(
    title: "ERES SEÑOR VENCEDOR",
    text: """
CANCIÓN: Eres señor vencedor
TONALIDAD: Am
TIEMPO: 155bpm

INTRO: Am - F 
Am
Eres Señor Vencedor El Invencible
F
Eres Campeón Ganador En Batalla
Dm                 E
Eres mi Rey y mi Dios
                   Am    G - E
El que Cuida a su Pueblo

CORO
          C      G           Am
//Por eso Yo Te canto y te alabo
Am   G  C           F                            
Porque sé Que me proteges
           Dm         G   *2° vez E *   
 porque estoy De tu lado//
""",
    tonalidad: "Am",
    tiempo: 155,
    multitrackLink: "https://youtu.be/OfbUgC77-ww",  
    youtubeLink: "https://youtu.be/hxFjyBWpIVk",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/yCs3-Bju_ro",
    ],
    guitarLink: [
      "https://youtu.be/Q0QZBG_ESvE",
      "https://youtu.be/e8vegDchLkk",
      "https://youtu.be/XorvUUa4Tx4",
      "https://youtu.be/alzSGyuuvxU",
    ],
    pianoLink: [
      "https://youtu.be/Hx41IhPOIVA",
      "https://youtu.be/Fi5nQlFALcY",
      "https://youtu.be/rrs17bnVLgs",
      "https://youtu.be/FEdn2vhzG-I",
    ],
    bassLink: [
      "https://youtu.be/_mbkwe_X7VE",
      "https://youtu.be/oL7JTDXsmrY",
      "https://youtu.be/KObLZVSw5r4",
      "https://youtu.be/P6yxj5BGf4Q",
    ],
    drumsLink: [
      "https://youtu.be/90avAS9I_fI",
      "https://youtu.be/eEZHW63ibj4",
      "https://youtu.be/LvFLIOUoRVM",
      "https://youtu.be/wN8pdyTie2A",
    ] 
  ),
  Song(
    title: "ERES TODOPODEROSO",
    text: """
CANCIÓN: Eres Todopoderoso - Rojo
TONALIDAD: Bm
TIEMPO: 130bpm

INTRO: // Bm G A - G A - G A //
  Bm                  G
La única Razón de mi adoración
D            F#m
Eres tú mi Jesús
   Bm              G
El único motivo para vivir
D            F#m
Eres tú Mi Señor

PRE-CORO:
      Bm           G
Mi única verdad está en Ti
         D              A
Eres mi luz y mi salvación
      Bm            G
Mi único amor eres Tú, Señor
        D             A
Y por siempre te alabaré

CORO:
        Bm        G
Tu Eres Todo poderoso
       D             A
Eres Grande y Majestuoso
      Bm            G
Eres Fuerte e Invencible
         D           A
Y no hay nadie como Tú

*solo de guitarra*
    Bm - G - D - A X4
CORO:
     C#m       A
Eres Todo poderoso
       E            B
Eres Grande y Majestuoso
      C#m           A
Eres Fuerte e Invencible
          E         G#7
Y no hay nadie como Tú

FINAL:// C#m A B - A B - A B //
""",
    tonalidad: "Bm",
    tiempo: 130,  
    multitrackLink: "https://youtu.be/5P3XUeiRVbk",  
    youtubeLink: "https://youtu.be/SepYuExIGlY?si=-ZY9ad-9_vCgMQjm",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/LOTee3aoKSs",
      "https://youtu.be/Abnz8Fyjiy8",
    ],
    guitarLink: [
      "https://youtu.be/ueLVspT645w",
      "https://youtu.be/UUkeOf-0yRk",
      "https://youtu.be/5U3S77rSKec",
      "https://youtu.be/WnjrH-4sWDE",
      "https://youtu.be/BInAnNLlSzQ",
    ],
    pianoLink: [
      "https://youtu.be/f9FNKz2-s2k",
      "https://youtu.be/cSktSmbCTA0",
    ],
    bassLink: [
      "https://youtu.be/IIp7aB72sjk",
      "https://youtu.be/yJ5TM9NM0iQ",
      "https://youtu.be/ihXtfQZ5e9Q",
      "https://youtu.be/gOaSUXCFevU",
    ],
    drumsLink: [
      "https://youtu.be/c20qC8ES_Uc",
      "https://youtu.be/a2Tc4qsjDsg",
      "https://youtu.be/qP2zL1oXVRg",
      "https://youtu.be/G3B19_TkqNs",
    ] 
  ),
  Song(
    title: "ERES TÚ",
    text: """
CANCIÓN: Eres tú - Danilo Montero
TONALIDAD: E
TIEMPO: 128bpm

INTRO: G#m - B - Db (x4)

G#m        E         B         F#7
 Jesús tu eres el amigo que me ama
G#m        E            B         F#7
Jesús tu eres la esperanza de mi vida
G#m   E     B   F#7
Eres, eres, eres tú
G#m   E    F#7
Eres, eres tú

G#m      E          B        F#7
Jesús tu eres el camino y la vida
G#m      E           B        F#7
Jesús tu eres salvación y alegría
G#m   E     B   F#7
Eres, eres, eres tú
G#m   E   F#7
Eres, eres tú

CORO
G#m       Db          E
  Tu eres Rey eres Señor
           B      F#7     G#m
Y en una cruz fuiste a vencer
        Db          E
Engrandecido eres Dios
         B    F#7      
Te levantaste con poder
// G#m - B - Db //
""",
    tonalidad: "E",
    tiempo: 128,
    youtubeLink: "https://youtu.be/iQ6dESF_6fI",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/IjmefqO9tzc",
    ],
    guitarLink: [
      "https://youtu.be/DYrIt4Y6rn0",
      "https://youtu.be/A3fcfVp53yo",
    ],
    pianoLink: [
      "https://youtu.be/6WdFOLcNxBY",
      "https://youtu.be/sieYaA-K0JI",
    ],
    bassLink: [
      "https://youtu.be/sZ86Jlsjucc",
      "https://youtu.be/ldTtLxGo41g",
    ],
    drumsLink: [
      "https://youtu.be/_apqtFDjSOg",
      "https://youtu.be/t6F5fbizc4A",
    ] 
  ),
  Song(
    title: "ES TIEMPO",
    text: """
CANCIÓN: Es Tiempo - Hillsong United
TONALIDAD: A
TIEMPO: 147bpm

INTRO:  
F#m - E - D - E X2  
Bm - F#m - D - E X2  
F#m A Bm A Bm F#m D E A

A                  
Amor inexplicable, 
                     F#m 
tu vida diste en la cruz,
 D             A
tuyo soy por siempre
    A                             
En tu misericordia, me diste vida,
        F#m D          A
 diste amor, tu gran amor

PRE-CORO
     E        F#m              D
Es tiempo de decidir por quien vivo
    E            F#m        D
Te seguire mi alabanza te dare, Jesús!!!!

CORO
    A
Por ti, por ti lo entrego todo
F#m                    D  
Solo a ti mi alabanza doy, 
                  A
toda mi alabanza doy
    A
Por ti, por ti es por quien vivo
    F#m                     D   
Te alabare con todo lo que soy, 
                  A
toda mi alabanza doy

PUENTE: F#m - D - A X2 
    F#m                          
/// Tuyo soy señor, 
Bm                D
vivo para darte gloria 
           A         E
oh Dios, gloria y honor///

PRE-CORO X2
CORO X2

FINAL
                   F#m
// Con todo lo que soy
        D         A
Toda mi alabanza doy//
""",
    tonalidad: "A",
    tiempo: 147,  
    youtubeLink: "https://youtu.be/OZzCl21qM-s?si=GuIeiYba9jDlwheH",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/fI0Noi_ImsI?si=JrqpV3X3Zo_RB0Yd",
      "https://youtu.be/ave4vWzSpGA?si=lBKroSutOA1Ix-7q",
      "https://youtu.be/MAgNQmvzuJY?si=rIcTPO8qTwJvxN70",
      "https://youtu.be/aVmWbEzPmks?si=DStHdJ0i1M7PONP_",
    ],
    pianoLink: [
      "https://youtu.be/yxm3NoMqh_c?si=rWE1Ir8HhkP6zv81",
    ],
    bassLink: [
      "https://youtu.be/0i5JriL01eA?si=lw4DsQ6R2oiPgHpw",
      "https://youtu.be/hu8MSc2d350?si=DX8SE-eFZmRfGmyI",
    ],
    drumsLink: [
      "https://youtu.be/aOIMCDhG0gQ?si=fEgd2prXz6qWFYVI",
      "https://youtu.be/lO9y87pceog?si=jW7D4y6RUVRkk4h7",
    ] 
  ),
  Song(
    title: "FIESTA",
    text: """
CANCIÓN: Fiesta - MSM
TONALIDAD: Cm
TIEMPO: 155bpm

INTRO: // Cm - Fm - Bb - G 
        ( Ab G Ab G G )//

VERSO:
          Cm                   
Lo que se canta en el cielo, 
    Fm
cantamos en la tierra
            Bb              
Al que se adora en el cielo, 
   G
Adoramos en la tierra 
          Cm                   
Lo que se canta en el cielo, 
    Fm
cantamos en la tierra
            C D Eb G // Ab F G //               
Al que se adora en el cielo, 
   G
Adoramos en la tierra 

PRE-CORO:
    Ab            Gm             
Al Santo (Santo), Digno (Digno), 
      Fm       Eb     
al Cordero (Cordero), 
     G
que vive para siempre

CORO
Hacemos
Cm                       Fm
 Fiesta, hoy hacemos una fiesta
Bb                  
Unidos hoy danzamos 
                     G Ab G Ab G Ab G
con gozo celebramos, oh uh oh uh oh
Cm                       Fm
Fiesta, Hoy hacemos una fiesta
Bb                              
En la tierra cantamos 
                 G Ab G Ab G Ab G
juntos gritamos, oh uh oh uh oh

INSTRUMENTAL
Acordes: Cm - Eb - F - Bb - Cm

PUENTE 2
   Cm      Ab      Cm      Ab
Hacemos Fiesta, Hacemos Fiesta
  Cm
Fiesta, Fiesta, Hacemos Fiesta, 
fiesta,Hacemos Fiesta, 
Fiesta, Fiesta, fiesta, fiesta//
""",
    tonalidad: "Cm",
    tiempo: 155,
    multitrackLink: "https://youtu.be/W5cO8IRDwGI",  
    youtubeLink: "https://youtu.be/Y3CphLiJ05U",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/CF-T0z4F8T0",
      "https://youtu.be/phwlJGum3io",
      "https://youtu.be/-oT3vrQ11oo?si=MW-mnDqzZsFVdn4O",
    ],
    guitarLink: [
      "https://youtu.be/U30ZoGTTa20",
      "https://youtu.be/5_C9TKauFno",
      "https://youtu.be/VIH5TDuG7os?si=ETUrK1-biYUajBbg",
      "https://youtu.be/IFSQNt3f424?si=PLsQr0OIoD0_Rus4",
    ],
    pianoLink: [
      "https://youtu.be/8dCaZF0FpJQ",
      "https://youtu.be/jYQuF5l9FK4",
      "https://youtu.be/iqGw97dfCIE?si=2QUuNviRLYjBTb00",
      "https://youtu.be/GEEjS0vpz6Y?si=gpyTV04OIdrd2ons",
    ],
    bassLink: [
      "https://youtu.be/YH1c6Ldlito",
      "https://youtu.be/Xut50cydNxI",
      "https://youtu.be/lJsurn1HsPE?si=0UWwE8yKSp6PtP_5",
      "https://youtu.be/N6ltntW-Aro?si=oSee5HbUuLXRk2qe",
    ],
    drumsLink: [
      "https://youtu.be/mLSDX0liuI8",
      "https://youtu.be/XSLly3Gzb4E",
      "https://youtu.be/Aw66lBjfXzI?si=JMowxfB2kMldQwi0",
      "https://youtu.be/6RyyYfTsFVo?si=WusUofZDRj9ytRWo",
    ] 
  ),
  Song(
    title: "GRANDE Y FUERTE",
    text: """
CANCIÓN: Grande y Fuerte - MSM
TONALIDAD: Am
TIEMPO: 150bpm

INTRO: Am - F - Em7    
 Am       F    Em7           Am F Em7
Grande y Fuerte es nuestro Dios (X4)

CORO
   Dm7           G      Dm7  
Vestido en majestad coronado 
      Am
con poder
       F       G        Am - G - A
Digno de toda la adoración
   Dm7           G      Dm7  
Vestido en majestad coronado 
      Am
con poder
       F       G     F  Em   Am
Toda gloria y honra sea para ti
*vuelve al intro una vez*

PUENTE
    Am   F Em7       Am   F Em7
¡¡Grande!!       ¡¡Fuerte!!
               Am   F Em7
¡¡Es nuestro Dios!! 

FINAL
        Am Am       G G      
////¡¡Grande!! y ¡¡Fuerte!! 
     F F      Em7
¡¡Es nuestro Dios!! ////
 Am                        
¡¡Grande!! y ¡¡Fuerte!! 
             Am Am G G F F Em7
Es nuestro Dios  
""",
    tonalidad: "Am",
    tiempo: 150,
    multitrackLink: "https://youtu.be/U86D0EPTLKs",  
    youtubeLink: "https://youtu.be/iJNnR83Ovts",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/iJNnR83Ovts",
    ],
    guitarLink: [
      "https://youtu.be/OfVRPfHM0fo",
      "https://youtu.be/GbYqK1A1yEM",
      "https://youtu.be/ciepZuNrRQY",
      "https://youtu.be/x3XCTwkBxH0",
      "https://youtu.be/ECVFcx5rgVE?si=Mw-iADqvtUOVhTAq",
    ],
    pianoLink: [
      "https://youtu.be/HGMNumLEm-Q",
      "https://youtu.be/SxVeKt057YQ",
    ],
    bassLink: [
      "https://youtu.be/_EZCNpo9yv8",
      "https://youtu.be/zhjbpWJoJYc",
      "https://youtu.be/7Ly1fznDMOg",
      "https://youtu.be/gEAGrkdJYa0",
    ],
    drumsLink: [
      "https://youtu.be/tHFw_-sanbQ",
      "https://youtu.be/S9MoeY6Rq-0",
      "https://youtu.be/egiISiqhyVM",
      "https://youtu.be/0SF36X1kRq0",
      "https://youtu.be/9l-h0_lJ8VM?si=knlktmdyThXurCW9",
    ] 
  ),
Song(
    title: "GRACIA SUBLIME",
    text: """
CANCIÓN: Gracia SUblime - Emir Sensini
TONALIDAD: A
TIEMPO: 104bpm
INTRO: // A - D //
VERSO 1:
A
   ¿Quién rompe el poder del pecado?
D
   Su amor es fuerte y poderoso
F#m                                     
   El Rey de gloria    
E                  D
   el Rey de majestad
A
   Conmueve el mundo con su estruendo
D
   Y nos asombra con maravillas
F#m                                     
   El Rey de gloria    
E                  D
   el Rey de majestad

CORO:
               A    
Gracia sublime es, 
                D
perfecto es su amor
             F#m  
Tomaste mi lugar  
                 E
cargaste tú mi cruz
               A     
Tu vida diste ahí 
               D      F#m
y ahora libre soy  o-o-o
               E  
Jesús te adoro   
                       A - D
por lo que hiciste en mí

VERSO 1:
A
  Pusiste en orden todo el caos, 
D  
  nos adoptaste como tus hijos
F#m                                     
   El Rey de gloria    
E                  D
   el Rey de majestad
A   
  El que gobierna con su justicia,  
D  
  y resplandece con su belleza
F#m                                     
   El Rey de gloria    
E                  D
   el Rey de majestad
(CORO)

PUENTE:
 A                            
Digno es el Cordero de Dios, 
 D
Digno es el Rey que la muerte venció (x3)
 F#m                    E           
Digno es el cordero de Dios,
         D
Digno, Digno, Digno.
""",
    tonalidad: "A",
    tiempo: 104,
     
    youtubeLink: "https://youtu.be/0c9j1U30614?si=AQpfKFDuwyvkoZW6",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/a-XSsmZbfhc?si=0Ju0_hWCiBwNT0DR",
      "https://youtu.be/5BPSuar-zNQ?si=5_on04JDxBsXdAxr",
    ],
    guitarLink: [
      "https://youtu.be/gEsAlXiiXVQ?si=ziur2pWx97FUn4E4",
      "https://youtu.be/uFb-otnd6nA",
      "https://youtu.be/LNVWnR24U_g?si=1UZ9P6fpk_o8cutG",
    ],
    pianoLink: [
      "https://youtu.be/V82RHcY3AYE?si=M0o_SfR2RRPwIVcn",
      "https://youtu.be/EIQ_HfmqmjI?si=GosH_G1K3oX4oRUO",
    ],
    bassLink: [
      "https://youtu.be/OpOAmv5Hal8?si=-O_K86Mv6uZZcMet",
      "https://youtu.be/aptAfpy2DJI?si=kMMpBOrGEKSNrWd2",
    ],
    drumsLink: [
      "https://youtu.be/Db8pIphGNI8?si=FDjCSzZz82UK_X1w",
      "https://youtu.be/IUyDL8RQ8LE?si=eRDp_NjkqWY8bcQU",
      "https://youtu.be/7lIkDKHGBxQ?si=DKbyNVrcHCkJsnyW",
    ] 
  ),
  Song(
    title: "HAS CAMBIADO - ADONAI",
    text: """
CANCIÓN: Has cambiado - Marcos Witt
TONALIDAD: Em
TIEMPO: 140bpm

INTRO: C C - D D - Em - Em D (X4)
           C         D        Em 
//Has cambiado mi lamento en baile
Em D  C           D    Em
Me ceñiste todo de alegría
Em - D  C          D        Em  
Has cambiado mi lamento en baile
Em D  C           D    Em
Me ceñiste todo de alegría

     G               D
Por tanto a ti cantaré
        C    D     Em
Gloria mía, gloria mía
 G              D
Sólo a ti danzaré
        C           B7
Gloria mía, gloria mía//

  Em          B - Em
//Oh Adonai  oh Adonai
  C   D      Em
Dios del universo
   B              Em
Señor de la creación//
        D                 G Gsus4
//Los cielos cuentan tu gloria
     D             G Gsus4
Tus hijos hoy te adoran
     B             Em     Am   B7
Por todas tus maravillas, Adonai//
""",
    tonalidad: "Em",
    tiempo: 140,
    multitrackLink: "https://youtu.be/utixbM3Ib_g",  
    youtubeLink: "https://youtu.be/8UKcmyGW4ak",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/T_CryTTX2Bk",
      "https://youtu.be/g8fXPQHwKi0",
      "https://youtu.be/vx3sH4vJ3bg",
      "https://youtu.be/l4cLKMwFH04",
    ],
    pianoLink: [
      "https://youtu.be/ql1P_BszNAA",
      "https://youtu.be/AAjL1ChdHRk",
      "https://youtu.be/rJnWO-V5aHA",
      "https://youtu.be/FaJuwRmcJ7c",
    ],
    bassLink: [
      "https://youtu.be/_yMpyKNEUEs",
      "https://youtu.be/ChOyei_ZMkM",
      "https://youtu.be/cFf09hmEbds",
      "https://youtu.be/Y6dcGNJ9Yvc",
    ],
    drumsLink: [
      "https://youtu.be/uVbdLJI_5V4",
      "https://youtu.be/o42c_GNGdaY",
      "https://youtu.be/3mkzMB1hMGE",
    ] 
  ),
  Song(
    title: "HAY LIBERTAD",
    text: """
CANCIÓN: Hay libertad - Art Aguilera
TONALIDAD: Dm
TIEMPO: 148bpm

Dm                         Bb
Hoy puedo danzar con libertad
              F     
Porque soy su hijo, 
              C
Porque soy su hijo
Dm                         Bb
Hoy puedo danzar con libertad
            F                   C
Porque soy amado,  Porque soy amado

INTRO: Dm - Bb - F - C
              Dm         
//Podemos sentir tu gozo, 
            Bb
Podemos sentir tu rio
         F                
Hay sanidad en las aguas,
             C
queremos danzar// 

CORO:
    Dm
Hay libertad en la casa de Dios
    Bb
Hay libertad en la casa de Dios
          F              C
Hay libertad,  Hay libertad

INSTRUMENTAL: // Dm C F Bb ... F C //
    Dm  C F         Bb
Hay libertad en la casa
    Dm  C F         C
Hay libertad al danzar

CORO 2:
         Dm
Puedo danzar en la casa de Dios
         Bb
Puedo danzar en la casa de Dios
          F           C
Puedo danzar y disfrutar

SALIDA:
             Dm
//Que somos libres
      Bb
Somos libres
        F            C
Por tu sangre libre soy//
       Bb
Libre soy.
""",
    tonalidad: "Dm",
    tiempo: 148,
    multitrackLink: "https://youtu.be/PMZDZsgPtFs",  
    youtubeLink: "https://youtu.be/NrBQK-AjBq8",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/PunrWqCDoH8",
      "https://youtu.be/pD-y3y-Zb-Y",
      "https://youtu.be/5L3lDpbv65s",
    ],
    guitarLink: [
      "https://youtu.be/OzLiIm12JaA",
      "https://youtu.be/fTi82MLmlnk",
      "https://youtu.be/12VX72HAC6U",
      "https://youtu.be/qzQaw6fOYvI",
      "https://youtu.be/MbopaSuHkPM?si=0uJLwE8B9VNTRuWM",
    ],
    pianoLink: [
      "https://youtu.be/Te_dHsnfgqE",
      "https://youtu.be/Bu4lkniroXU",
      "https://youtu.be/GsXoWb2cbsQ",
      "https://youtu.be/cMSt0_iKk3w",
    ],
    bassLink: [
      "https://youtu.be/C5jUxMcMysg",
      "https://youtu.be/o08f9pyXvow",
      "https://youtu.be/n0yS1cOuCyk",
    ],
    drumsLink: [
      "https://youtu.be/N4dWwDkNTZY",
      "https://youtu.be/qn1gW5LYnBs",
      "https://youtu.be/mWLGR7LRwpg",
      "https://youtu.be/aeCOKa2sklg",
      "https://youtu.be/xZC9tNuNa3E",
      "https://youtu.be/e7rwz6o7Glo",
    ] 
  ),
  Song(
    title: "HOY ES TIEMPO",
    text: """
CANCIÓN: Hoy es tiempo - MCLV
TONALIDAD: Bm
TIEMPO: 150bpm 

INTRO: // Bm - G - D - A //
  Bm
//Hoy es tiempo de celebrar
 G
todos unidos vamos a cantar 
   D
tomados de las manos 
            A
vamos a danzar//

CORO:
     Bm
Danzaré ,danzaré 
        G
me gozaré, me gozaré 
      D                      A
con gritos de jubilo celebraré
""",
    tonalidad: "Bm",
    tiempo: 150,
    instrument: 0,
  ),
  Song(
    title: "HOSANNA",
    text: """
CANCIÓN: Hosanna - Marco Barrientos
TONALIDAD: Bm
TIEMPO: 146bpm

INTRO: // Bm - A - F#m - G // 
Bm           A
  Levantamos un clamor
F#m               G
   por sanidad y redención
Bm                  A
    Muestranos lo que tú ves
F#m                    G
    los secretos de tu corazón.
Bm                  A
   Un pueblo unido pide hoy
F#m                 G
     Tu libertad y salvación
Bm              A
   Armanos con Tu valor
F#m                      G
    lo que deseamos es revolución.

PRE-CORO:
G                           A          
  Que el cielo se parta en dos... 
        Bm
  inundanos
                        A        
en el desierto broten rios... 
            Bm
vida sopla hoy

CORO:
Bm                          D
// Hosanna al Rey de Salvación
                      Em
Hosanna al Dios AltÍsimo
          G          
Hosanna, Jesucristo, 
 A             Bm
Jesucristo es Rey //

SOLO: /// G - A /// Bm - F#m

PUENTE:
G        A        G  A       Bm  F#m
  Hosanna Hosanna Hosanna al rey
""",
    tonalidad: "Bm",
    tiempo: 146,
    multitrackLink: "https://youtu.be/qMyn1LxvgBw",  
    youtubeLink: "https://youtu.be/umPWpA8-FXU?si=YM1E6bY8-yD287rL",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/I55pgZ1bsRA",
      "https://youtu.be/uoMfK8lx5fk",
    ],
    guitarLink: [
      "https://youtu.be/8h3uxlBAvC0",
      "https://youtu.be/HogsXfC4PM0",
      "https://youtu.be/C16_xKKy4O4",
      "https://youtu.be/hFbR2_C_rNw",
    ],
    pianoLink: [
      "https://youtu.be/HUWtRn3PiTQ",
      "https://youtu.be/Q2_-1U-jPrI",
      "https://youtu.be/KVCpeW1EDYc",
      "https://youtu.be/J0fmkuI2zbw",
    ],
    bassLink: [
      "https://youtu.be/TmwugoRm2R8",
      "https://youtu.be/vNXbrNcyTqI",
      "https://youtu.be/t-nd7jbzeLo",
      "https://youtu.be/yULROu6dFdE",
    ],
    drumsLink: [
      "https://youtu.be/MN56dxSEVl8",
      "https://youtu.be/1hvLR9wf0gk",
      "https://youtu.be/gCsYgKfeW0E",
      "https://youtu.be/aTGR5WP6Gi8",
    ] 
  ),
  Song(
    title: "INCREÍBLE",
    text: """
CANCIÓN: INCREÍBLE - MSM
TONALIDAD: C       
TIEMPO: 132bpm

INTRO: F - C - G - Am ( Em ) 
F            C
   Poderoso,    invencible
G              Am               F
   admirable, grande y fuerte Dios
                 C        
   Rey de Reyes,    asombroso,
G                 Am
   incomparable...

CORO:
          F     C
Eres increi....ble
G               Am
todopoderoso, grande
          F     C
eres increi....ble
    G
venciste las tinieblas
 Am               *vuelve al intro*  
Cristo exaltado estas...

PUENTE:
     F           C
Increíble, invencible
     G                Am
mi Dios solo tú, solo tú
     Em      F          C
Tu eres increíble, invencible
     G                Am
Mi Dios solo tú, solo tú...

INSTRUMENTAL: 
// F - C - G - Am //
""",
    tonalidad: "C",
    tiempo: 132,
    multitrackLink: "https://youtu.be/e1_6T8f7bjo?si=_7qeVOIBQPtF_rgk",  
    youtubeLink: "https://youtu.be/It5aj55TykY",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/-DcEb6Eq6ls",
      "https://youtu.be/Sz3xHjedtms",
      "https://youtu.be/HeIL0rAMKq8",
      "https://youtu.be/V0vwEDbdUYU",
    ],
    guitarLink: [
      "https://youtu.be/4JPGyOT84lI",
      "https://youtu.be/0X3cEM-siyk",
      "https://youtu.be/31WEnX9BgNY",
      "https://youtu.be/xJxefnWaZ_U",
      "https://youtu.be/G1PUHCm_uLA",
    ],
    pianoLink: [
      "https://youtu.be/9iYFn708hL0",
      "https://youtu.be/XG5ZTlZmMss",
      "https://youtu.be/tGnpgguQ7MQ",
      "https://youtu.be/jpFEd6KXp7Q",
      "https://youtu.be/EgBh8cqNJ6k",
    ],
    bassLink: [
      "https://youtu.be/JFKjJVcoGIY",
      "https://youtu.be/hwIlx8Uiw2Q",
      "https://youtu.be/DjbCosWNeXU",
      "https://youtu.be/tc508qAj0rA",
    ],
    drumsLink: [
      "https://youtu.be/zIiA-jBEbFU",
      "https://youtu.be/2-wd8CjdGa0",
      "https://youtu.be/5fXJWQSRGCY",
      "https://youtu.be/Gp21ueXne0w",
    ] 
  ),
  Song(
    title: "JEHOVÁ ES MI FORTALEZA",
    text: """
CANCIÓN: Jehová Es Mi Fortaleza - MCLV
TONALIDAD: Dm
TIEMPO: 142bpm

INTRO: Dm - C - Bb - A
    Dm
Jehová es mi fortaleza
     C
mi Dios mi salvador
Bb                       A
él es mi escudo mi protector
Dm                       C
Él me librará de la tormenta
        Bb                       A
con sus lazos de amor me sostendrá

CORO:
  Dm              C
//Poderoso Dios grande en batalla
   Bb                      A
si tú estás conmigo no temeré//
""",
    tonalidad: "Dm",
    tiempo: 142,
    instrument: 0,
  ),
  Song(
    title: "JEHOVÁ ES MI GUERRERO",
    text: """
CANCIÓN: Jehová es mi guerrero
TONALIDAD: Em
TIEMPO: 146bpm

       Em                
///Jehová es mi guerrero, 
C   D // Em Em D //
oh, oh, oh ///
    Em                 
Jehová es mi guerrero, 
C   D   E
oh, oh, oh 
CORO
Am              Em
Con mi alabanza pelearé
   C       D      Em
no es mi guerra sino la de dios
Am              Em
danza y pandero yo daré
   C       D      Em
no es mi guerra sino la de dios
Am                 Em
címbalo y trompeta sonaré
   C       D      Em
no es mi guerra sino la de dios
     Am            Em         B7
con fuerte y alta voz yo gritaré.
FINAL: C - D - C - D - Em
""",
    tonalidad: "Em",
    tiempo: 146,
    youtubeLink: "https://youtu.be/oXUW6jxRwEk",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/oXUW6jxRwEk",
      "https://youtu.be/bMgYE2JOaXE",
      "https://youtu.be/VfpPpngpItk",
    ],
    guitarLink: [
      "https://youtu.be/izsydxOiaqA",
      "https://youtu.be/3-QWsRm6b98",
      "https://youtu.be/82idV5lTuRE",
    ],
    pianoLink: [
      "https://youtu.be/MeR-0oHGVRU",
      "https://youtu.be/vnWibcpYrEA",
      "https://youtu.be/s8L0r7ipa8c",
    ],
    bassLink: [
      "https://youtu.be/VG45HJMcb3M",
      "https://youtu.be/q_jtkNMmT_I",
    ],
    drumsLink: [
      "https://youtu.be/CF3cz6kdrSo",
      "https://youtu.be/3EaLwG6lUlk",
      "https://youtu.be/X72yzdY6Hgg",
    ] 
  ),
  Song(
    title: "JEHOVÁ ES MI LUZ",
    text: """
CANCIÓN: Jehová Es Mi Luz - MCLV
TONALIDAD: Am
TIEMPO: 138bpm

INTRO: Am - F - C - G
    Am           F
Jehová es mi luz y mi salvación
     C                       G
Jehová es la fortaleza de mi vida
Am                   F
Aunque un ejército acampé contra mi
C                 G
no temerá mi corazón

PRE-CORO:
         Am               F
//No temeré........no temeré
 C                     G
aunque contra mi se levanten//

COR:
         Am
//Remolineando Remolineando
    F
Danzando Danzando
      C                       G
celebrando la victoria del señor//
""",
    tonalidad: "Am",
    tiempo: 138,
    instrument: 0,
  ),
  Song(
    title: "LA CASA DE DIOS",
    text: """
CANCIÓN: La casa de Dios - 
Danilo Montero
TONALIDAD: D
TIEMPO: 143bpm

INTRO: // D A Bm G - D A G //
VERSO 1
   D         A        Bm        G
Mejor es un día en la casa de Dios
     D        A       Bm    G
Que mil años lejos de Él
     D          A        Bm       G
Prefiero un rincón en la casa de Dios
     D         A           Bm
Que todo el palacio de un rey
     D         A           G
Que todo el palacio de un rey

CORO:
       D                   A
Ven conmigo a la casa de Dios
       Bm                G
Celebraremos juntos su amor
          D                   A  
Haremos fiesta en honor de aquel 
          G
que nos amó
           D                 A
Estando aquí en la casa de Dios
      Bm            G
Alegraremos su corazón
          D                A          
Le brindaremos ofrendas de obediencia 
    G
y amor
                 INTRO
¡En la casa de Dios!

VERSO 2:
D        A    Bm        G
Arde mi alma, arde de amor
D              A        Bm G
Por aquel que me dio la vida
    D        A    Bm      G
Por eso le anhela mi corazón
  D        A       Bm
Anhela de su compañía
  D        A       G
Anhela de su compañía
""",
    tonalidad: "D",
    tiempo: 143,
     
    multitrackLink: "https://youtu.be/I1VNf9h1zTU?si=u5bELci0sk17MNsP",  
    youtubeLink: "https://youtu.be/NZWpRP6IJuI",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/0hctWiI9Vwc?si=3zpYgurwUOWnfWkc",
      "https://youtu.be/wqIYpWwWa50?si=hKS8g3or8uKZNtY8",
      "https://youtu.be/rVF044NuJ8U",
      "https://youtu.be/GBnnL_VUm2c",
    ],
    guitarLink: [
      "SOLO GUITARRA ELECTRICA",
      "https://youtu.be/_9NMsXLoL9Y?si=UvuzxjZrAMkSqEtB",
      "https://youtu.be/dXJt1cRoWUg",
      "https://youtu.be/Las70tR26tw",
    ],
    pianoLink: [
      "https://youtu.be/u2i08qyyE7c?si=PztxTqQRc3J5J0Q2",
      "https://youtu.be/WCcmrYsS5JI?si=OicNOYSdgds1idQT",
      "https://youtu.be/gDDQbhtnz_I",
      "https://youtu.be/OpMf4t_Mo00",
    ],
    bassLink: [
      "https://youtu.be/qJ2mqgKNDEA?si=G7rm7HNQkONvi_8m",
      "https://youtu.be/kOtgmPdhsP8?si=PbhS9Yvl3yprxg6g",
      "https://youtu.be/VRI0R12vY_g",
    ],
    drumsLink: [
      "https://youtu.be/L3QP5qq7FtA?si=A0-r3orxqVQwErNN",
      "https://youtu.be/pLol6aLgOXw?si=ehXug-mtVZs_lcgv",
      "https://youtu.be/gCh_kWqYrNM",
      "https://youtu.be/1enyGnlFNWc",
    ] 
  ),
  Song(
    title: "LA COSECHA",
    text: """
CANCIÓN: Será llena la tierra
TONALIDAD: Am
TIEMPO: 148bpm

INTRO:  Am *PIANO*
Am               F
alza tus ojos y mira 
C                G
la cosecha esta lista 
    Am           G
el tiempo ha llegado 
    F            E
la mies esta  madura 
   Am               F 
esfuérzate y se valiente 
   C            G
levántate y predica 
  Am            G
a todas las naciones 
      F           E
que cristo es la vida 
 
CORO
  Am G F    G            E           
\\y será ah ah llena la tierra 
         Am
  de su gloria 
   Am G F      G          E      
se cubrirá ah ah como las aguas 
            Am
  cubren la mar//
""",
    tonalidad: "Am",
    tiempo: 148,
    youtubeLink: "https://youtu.be/wvCz-CHAljk",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/wuga4qqwSJQ",
      "https://youtu.be/ifF4-ux08-E",
      "https://youtu.be/NDNiyxi-dtE",
    ],
    pianoLink: [
      "https://youtu.be/JZjveH1keNM",
      "https://youtu.be/sfZO4eclNbU?si=VPkz2VtRmClGaeLN",
    ],
    bassLink: [
      "https://youtu.be/REwjxlaHwp4",
      "https://youtu.be/tC_g2uPV14s",
    ],
    drumsLink: [
      "https://youtu.be/HxWFyXvebF8",
      "https://youtu.be/JDZfdZ9BlaU",
      "https://youtu.be/JfJC5a-qHTI",
    ] 
  ),
  Song(
    title: "LEVÁNTATE",
    text: """
CANCIÓN: Levántate
TONALIDAD: Am
TIEMPO: 155bpm

INTRO: F - C - G - Am  Am G F
          C     G       Am Am G F
//Levántate, levántate Señor
            C        E             Am
que tus enemigos huyan delante de ti//

CORO:
Am - G - F               C
Mas los justos se alegrarán
      G           Am
cantarán con regocijo
Am  G F              C
el Señor se ha levantado
       E7         Am
a triunfado con poder 
""",
    tonalidad: "Am",
    tiempo: 155,
    youtubeLink: "https://youtu.be/C29aPbSGaeI",
    instrument: 1,
    voicesLinks: [
      "https://www.youtube.com/watch?v=kXMMSKeIkKI&ab_channel=NelsonAndré",
    ],
    guitarLink: [
      "https://youtu.be/6e60hFS7KgE",
      "https://youtu.be/pnK5BOU9ecI",
      "https://youtu.be/b_pTSTeGMXg",
    ],
    pianoLink: [
      "https://youtu.be/kRJqgJXOYug",
      "https://youtu.be/shfDmskLdHc",
      
    ],
    bassLink: [
      "https://youtu.be/gO7RoshRLfk",
      "https://youtu.be/x26NFXLg2ws",
      "https://youtu.be/jc1uoQqaAl0",
    ],
    drumsLink: [
      "https://youtu.be/aZOmhBAQupk",
      "https://youtu.be/NeDuYLrPO0Q",
      "https://youtu.be/mtEMIT7uUB0",
      "https://youtu.be/jbOHFsd7uw0",
    ] 
  ),
  Song(
    title: "LEVÁNTATE SEÑOR",
    text: """
CANCIÓN: Levántate Señor
TONALIDAD: Cm(original)-Bm(iglesia)
TIEMPO: 133bpm

  Bm            A         Bm  G - A 
//Levántate, levántate Señor
Bm             D C#   A Bm
levántate, levántate Señor//

PRE-CORO
Em                   A     Bm      
Huyan delante de ti tus enemigos
A Bm Em                    F#
se dispersan delante de ti todos aquellos
                    Bm 
que aborrecen tu presencia  

CORO:
       Em            
Tu presencia reinara,
 A            Bm
 sobre todo imperio
Bm   A Em                F#7     
tu presencia reinara, gobernará 
                 Bm
sobre todo principado

INSTRUMENTAL: // Bm - G - A // 

PUENTE 1
Bm           A – Bm   G A   
Espíritu de te - mor Huye! 
  Bm      D  C# Bm   G A
Espíritu de mal-dad Huye!
Bm           A – Bm     G A  
Espíritu de ren - cor ¡Huye! 
   Bm          G    F#
Espíritu de divi – sion Huye!
Bm             A – Bm    G A   
Espíritu de enfermedad ¡Huye! 
   Bm       D  C# Bm  G  A
Espíritu de rebelión ¡Huye!
Bm            A – Bm   G A   
Espíritu de inmo-ral ¡Huye! 
  Bm          G    F# (Repite Coro)
Espíritu de oscuri-dad ¡Huye!

INSTRUMENTAL: // Bm - G - A // 
PUENTE 2
*misma figura del PUENTE 1*
Espíritu de perversion  ¡Huye!   
Espíritu de ambicion   ¡Huye!
Espíritu de profanador  ¡Huye!   
Espíritu de  vanidad     ¡Huye!
Espíritu de murmuración  ¡Huye!   
Espíritu de contencion ¡Huye!
Espíritu de hechizeria  ¡Huye!   
Espíritu de mortandad   ¡Huye!
""",
    tonalidad: "Bm",
    tiempo: 133,
    youtubeLink: "https://youtu.be/Ju7E48Cpdgk",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/POczXwN3GaE",
      "https://youtu.be/FJliXXSqVpk",
    ],
    pianoLink: [
      "https://youtu.be/YoIvhIky528",
      "https://youtu.be/P7fyFZEjJ9Y",
    ],
    bassLink: [
      "https://youtu.be/jf-YYDf5ej8",
      "https://youtu.be/n4Vf0-0q4MY",
      "https://youtu.be/F3acvNivk78",
    ],
    drumsLink: [
      "https://youtu.be/xtJX5ZuKnno",
      "https://youtu.be/Y9Iu6hGtQc4",
    ] 
  ),
  Song(
    title: "LOS MUROS CAEN",
    text: """
CANCIÓN: Los muros caen
TONALIDAD: Em
TIEMPO: 142bpm

INTRO: Em
          Em
Los muros caen
Los muros caen
      Am           Em
Y con ellos las cadenas
Los muros caen
Los muros caen
       Am              Em
Se derrumban las fortalezas

CORO
      Am       D         G         Em
El Señor entregó en mis manos Jericó
   C    B
Grita ¡Hey!
            Em
Toca la trompeta
""",
    tonalidad: "Em",
    tiempo: 142,
    youtubeLink: "https://youtu.be/6oyIsaiIZ9I?t=525",
    instrument: 1,

    guitarLink: [
      "https://youtu.be/voWV8rEuV98",
    ],
    pianoLink: [
      "https://youtu.be/8GARPjzNWYc",
      "https://youtu.be/voWV8rEuV98",
    ],
    bassLink: [
      "https://youtu.be/S3n-jLPVgyU",
      "https://youtu.be/-pib5GtLtIQ",
    ],
    drumsLink: [
      "https://youtu.be/fa-_inUR3ZA",
      "https://youtu.be/1nbH1jDz968",
    ] 
  ),
  Song(
    title: "LOS MUROS CAERÁN",
    text: """
CANCIÓN: Los muros caerán
TONALIDAD: Cm
TIEMPO: 152bpm

INTRO: Cm - Ab - Bb - Cm
    Cm               Bb
Cuando le canto la tierra se estremece
    Ab     Bb     Cm
los muros     caerán
    Cm              Bb
cuando le adoro se rompen las cadenas
    Ab    Bb    Cm
Los muros   caerán

CORO:
    Cm                Ab
Los muros caerán  los muros caerán
             Bb     Gm     Cm
Al sonar mi cantico    caerán
Cm                Ab
Los muros caerán  los muros caerán
               Bb     Gm     Cm
con gritos de jubilo     caerán

VERSO 2:
    Cm            Bb
cuando yo danzo aumenta Dios mis fuerzas
    Ab    Bb     Cm
los muros    caerán
    Cm              Bb
cuando yo grito mis enemigos huyen
       Ab  Bb     Cm
los muros     caerán
*vuelve al coro*

PUENTE:
         Cm    Bb
Caen los muros,  caen los muros (x8)

Ab          Bb           Cm        Bb
//Saltando, saltando los muros caerán
   Ab        Bb         Cm       Bb
Gritando, gritando los muros caerán//
""",
    tonalidad: "Cm",
    tiempo: 152,
    multitrackLink: "https://youtu.be/ldSB2a112Rs?si=dxIoglzW6z4nBH36",  
    youtubeLink: "https://youtu.be/nyrMayW_8oo",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/htjxCsIzLsQ?si=aezZE6NlOjZzC8iW",
      "https://youtu.be/-ILfWzRtcY4?si=Gfrs8oR9Br48hGGU",
      "https://youtu.be/nyrMayW_8oo",
    ],
    guitarLink: [
      "https://youtu.be/RExZ5KCa7Po?si=FXYD7151MF6TdYOy",
      "https://youtu.be/JOkdDlyoPHE?si=-JU99FouH6mHd9hR",
      "https://youtu.be/9DQtU4yWm40",
      "https://youtu.be/oIh1ZeWQT-g",
    ],
    pianoLink: [
      "https://youtu.be/mIqKxC1ehNI?si=Q22x3VIfadzrIM9L",
      "https://youtu.be/f4w7yRxLfcQ?si=UOwZBuKnUsFMEWjz",
      "https://youtu.be/k_DCayJnYng",
      "https://youtu.be/_pAl6rWZ_O0",
    ],
    bassLink: [
      "https://youtu.be/6UpaiuoalwA?si=r-oFXNhVn5OATJn7",
      "https://youtu.be/kCQWLTFEn50?si=alXqh_yFiocKr2Rr",
      "https://youtu.be/ZuDGyfZKRz4",
      "https://youtu.be/zcnk2K4Ld98",
    ],
    drumsLink: [
      "https://youtu.be/o5v94P8jSR0?si=Wy8akuxrHk-6bmJz",
      "https://youtu.be/hzyfdgUYz1s?si=-FQoWSK8etLgu0ia",
      "https://youtu.be/RJTB9nVJziQ",
      "https://youtu.be/jL6PVW_MONw",
      "https://youtu.be/jL6PVW_MONw",
    ] 
  ),
  Song(
    title: "MARAVILLOSO ES EL SEÑOR",
    text: """
CANCIÓN: Maravilloso es el señor
TONALIDAD: Em
TIEMPO: 137bpm

INTRO: Em - D - C - B
VERSO:
Em                   D
Maravilloso es el Señor Jesús
       C           B
Quien reina con poder, poder
2° vez  Poder, poder, poder

CORO:
          Am  D           G  Em
El es mi Rey,   Él es mi Rey
         C    D    Em
Y en su casa danzaré
""",
    tonalidad: "Em",
    tiempo: 137,
    youtubeLink: "https://youtu.be/AjxvwmUD8ps",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/bjOO4u-7Ezg",
      "https://youtu.be/taeYbZfa890",
    ],
    pianoLink: [
      "https://youtu.be/ZPrj0m7Yzno",
      "https://youtu.be/8qnJBXlpPO0",
    ],
    drumsLink: [
      "https://youtu.be/l2wD4uF714s",
    ] 
  ),
  Song(
    title: "ME GOZARÉ",
    text: """
CANCIÓN: Me gozaré - MSM
TONALIDAD: Am
TIEMPO: 155bpm

INTRO: // Am - G - Dm - E //
              Am
//Cuando el Señor hiciere volver
              G
De la cautividad
        Dm               E
seremos como los que sueñan//
     Am
//Mi boca llenará de risa,
     G
mis labios de alabanza,
   Dm
Entonces dirán las naciones
         E
Grandes cosas ha hecho el Señor//

CORO
         Am
//Me gozaré, me gozaré,me gozaré,
                  G
me gozaré en Jehová
           Dm
Pues ha llevado todo mi dolor,
              E
 me ha hecho libre//
""",
    tonalidad: "Am",
    tiempo: 155,
     
    multitrackLink: "https://youtu.be/5IFXcYRqRdI",  
    youtubeLink: "https://youtu.be/nfjVQkFwb9A?t=534",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/UWrl33jz6xo",
    ],
    guitarLink: [
      "https://youtu.be/nzxYqRILQSs?t=1509",
      "https://youtu.be/Di1HgcHwRjI",
      "https://youtu.be/nFyQJRBJJM0",
    ],
    pianoLink: [
      "https://youtu.be/SrBYg3FZ69A?t=532",
      "https://youtu.be/1LemQ6cQHEM",
      "https://youtu.be/in11uJxaxEQ",
    ],
    bassLink: [
      "https://youtu.be/C2bX1WekTWg?t=537",
      "https://youtu.be/nEhX48z8rY8",
      "https://youtu.be/n6FIvGngslM",
    ],
    drumsLink: [
      "https://youtu.be/o__aF59aWjk?t=535",
      "https://youtu.be/J1kEQVqXDUY",
      "https://youtu.be/I7TQXViwFBE",
    ] 
  ),
  Song(
    title: "MI DIOS ES GRANDE Y FUERTE",
    text: """
CANCIÓN: Mi Dios es grande y fuerte - 
Omar Oropeza
TONALIDAD: Am
TIEMPO: 160bpm

INTRO: Am - F - G
    Am               Em
Mi Dios es grande y fuerte
   Dm        Em
y su palabra vence,
     Am        G           F       E
sus enemigos tiemblan y huyen ante Él

CORO:
 Am G F    G        E      Am
Jesucristo es el Señor, mi Rey,
 Am   G  F      G
y en su nombre hay,
       E           Am
hay poder para vencer
""",
    tonalidad: "Am",
    tiempo: 160,
    youtubeLink: "https://youtu.be/kp-ZZ9QseCw",
    instrument: 1,
    voicesLinks: [
      "https://www.youtube.com/watch?v=2pzxhxFq3ao&ab",
    ],
    guitarLink: [
      "https://youtu.be/65U9P4uiN68",
      "https://youtu.be/HncdjvCOzpI?si=1wbXv7tH6SEQsbdm",
      "https://youtu.be/U14AKgyqgUw?si=sWSShtU7dID64DGK",
    ],
    pianoLink: [
      "https://youtu.be/YkOjGF6hofA",
      "https://youtu.be/YIHR7oocwaU",
    ],
    bassLink: [
      "https://youtu.be/eFrP23OtkPE",
    ],
    drumsLink: [
      "https://youtu.be/KoM1FlzL9SE",
      "https://youtu.be/3KbdytWPEUM",
      "https://youtu.be/0D66fnIGc-g",
    ] 
  ),
  Song(
    title: "NO HAY TORMENTAS",
    text: """
CANCIÓN: No hay tormentas - MCLV
TONALIDAD: Em
TIEMPO: 145bpm

INTRO: Em - C - D - Em
Em
   No hay tormentas
         D         Em
que nos puedan destruir
Em
    no hay gigante
         D          Em
que nos puedan detener

PRE-CORO
          C
Por más grande
              D
sean mis problemas
C         D   Em
tengo al vencedor
        C           D
en sus manos voy seguro
  C      D   Em
y no me rendiré

CORO
        C   D               Em
Porque soy más que un vencedor
C   D       Em
en Cristo Jesús
     C          D
si Dios está conmigo
  C    D     Em
quien contra mi
        C   D               Em
Porque soy más que un vencedor
C   D       Em
en Cristo Jesús
         C           D
en sus brazos voy seguro
C    D       Em
él me sostendrá
""",
    tonalidad: "Em",
    tiempo: 145,
    instrument: 0,
  ),
  Song(
    title: "PODEROSO DE ISRAEL",
    text: """
CANCIÓN: EL PODEROSO DE ISRAEL
TONALIDAD: Bm (ORIGINAL Cm)
TIEMPO: 148bpm

VERSO 1
     Bm
Y de noche cantaremos, 
celebrando su poder
                   F#7
Con alegría de corazón
            Em         F#7    
Como el que va con la flauta 
     Em         F#7
a la casa del Señor
                  Em 
Celebraremos su poder

CORO
F#7 G A Bm            
Él es el Poderoso de Israel
                  F#7
El Poderoso de Israel
             Em F#7
Su voz se oirá
               Em F#7       
Nadie lo detendrá
                   Em 
Al Poderoso de Israel

VERSO 2
      Bm              
Y los ojos de los ciegos 
se abrirán y ellos verán
                           F#7
Los oídos de los sordos oirán
              Em  
El cojo saltará, 
     F#7        Em
con el arpa danzará
  F#7                        Em 
La lengua de los mudos cantará
""",
    tonalidad: "Bm",
    tiempo: 148,
    youtubeLink: "https://youtu.be/eVeWjKgEzWI",
    instrument: 0,
    /*voicesLinks: [
      "",
    ],
    guitarLink: [
      "",

    ],
    pianoLink: [
      "",
    ],
    bassLink: [
      "",
    ],
    drumsLink: [
      "",
    ] */
  ),
  Song(
    title: "TE ALABARÉ",
    text: """
CANCIÓN: Te alabaré - ROJO
TONALIDAD: E
TIEMPO: 120bpm

INTRO: // E - B - C#m - A //
E              B
Eres tú la única razón
       C#m            A
De mi adoración oh Jesús
E                B
Eres  tú la esperanza que
   C#m            A
Anhelé tener oh Jesús
F#m                       B
  Confié en ti me has ayudado
  D                      B
  Tu salvación me has regalado
 E                      B
Hoy hay gozo en mi corazón
        A             B
Con mi canto te alabaré

CORO:
 Gb          Db  D#m          B
//Te alabaré,    te glorificaré
Gb        Db            B 
Te alabaré   mi buen Jesús//

PUENTE:
E                       B
En todo tiempo te alabaré
C#m      A             B
En todo tiempo te adoraré

INSTRUMENTAL: E - C - D - Bm
CORO:
 G          D    Em          C
//Te alabaré,    te glorificaré
G        D              C 
Te alabaré   mi buen Jesús//

SALIDA: E - C - D - Bm
""",
    tonalidad: "E",
    tiempo: 120,
    multitrackLink: "https://youtu.be/HqShedNqgbo",  
    youtubeLink: "https://youtu.be/gXN-ccl4x9Y?si=Tz0JO57JDaS1mEbD",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/ikI2EFc5MCE?si=rkWDcgi4qaJ32MK9",
    ],
    guitarLink: [
      "https://youtu.be/oCOJavNHq-4",
      "https://youtu.be/cPBBcAyDMuA",
      "https://youtu.be/1D8ijMZ4jnM?si=jspYQrcKYlSik4KY",
      "https://youtu.be/Z50yWfqubuE?si=K4HBGqrmdG3i42bc ",
    ],
    pianoLink: [
      "https://youtu.be/M_Fclbf5FTw",
      "https://youtu.be/ujDuGCIXF1A",
      "https://youtu.be/iMWSDeiLanw?si=juSXwzMW4qSlmty7",
      "https://youtu.be/fnzoJreZGK8?si=9uJJ96Rh4Qyl2IXE",
    ],
    bassLink: [
      "https://youtu.be/8lqAJhy2OR4?si=BEDNBUsW_f0v5zf_",
      "https://youtu.be/kc1bbirw_cU?si=gtTXX5s0PcAEMNDi ",
    ],
    drumsLink: [
      "https://youtu.be/rIs8wjdLziU",
      "https://youtu.be/oqiL3e9e53w",
      "https://youtu.be/me9mUw5XfsU?si=hLTZYivoywJzVzt5",
      "https://youtu.be/XhfGaJ6I8Yw?si=cbnVK_rUuPDvEKIv",
    ] 
  ),
  Song(
    title: "TÓMALO",
    text: """
CANCIÓN: TÓMALO - Hillsong United
TONALIDAD: B
TIEMPO: 152bpm

INTRO: B  Bbm  D#m
VERSO 1:
B
De todo lugar los perdidos vendrán
                 Bbm    D#m
En libertad a Ti clamarán
B
Llevaste la cruz moriste y vivo estas
                Bbm   D#m
Mi Dios, a ti mi vida te daré

( INTRO )

VERSO 2:
B
Enviaste a Jesús, por mi salvación
                         Bbm D#m
Por la eternidad en ti tengo perdón
B                                G#m
Busque la verdad y Te encontré a Ti
          E
Mi Dios a Ti mi vida te daré

CORO:
B           F#
 Jesús, por ti yo viviré
      G#m                E
De ti nunca me avergonzaré
B       F#
 Te doy todo lo que soy
C#m
Tóma, Tómalo
C#m
Tóma, Tómalo

PUENTE:
C#m          G#m      F#    E
Eres el que vista al ciego das
C#m           G#m    F#
Brillas en la oscuridad
   C#m          G#m     F#     E    
La salvación del mundo en tus manos 
   B
está.

( BAJO )
( CORO )
""",
    tonalidad: "B",
    tiempo: 152, 
    youtubeLink: "https://youtu.be/3oAOq4kB1o4?si=aH5ANc1S6dtcEIXZ",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/RCwo1_7QHis?si=txfakt1YLiQfIz6u",
      "https://youtu.be/cny3CpgaBZI?si=oQ0Yxb3HHJPVK620",
      "https://youtu.be/ydfy9MH_IFc?si=jvk_yvQZ98EmnnBi",
    ],
    pianoLink: [
      "https://youtu.be/HstIHbcGWyY?si=x3Bp595p6JJCf71u",
      "https://youtu.be/5m5m2DIO1Pc?si=sa27vWpeh3HSbZbA",
    ],
    bassLink: [
      "https://youtu.be/NPHmAWI7OXY?si=18CC51SllTH2w_Cw",
      "https://youtu.be/4oYrAzxf8sU?si=3_9qRQ1igGoze_uB",
      "https://youtu.be/3EL1eoljk_k?si=XFbKcTBobQYNZXkq",
    ],
    drumsLink: [
      "https://youtu.be/Cqu1XtCSZlA?si=8Z2hYiC0gujxdlB1",
      "https://youtu.be/FzvxmBzw9DQ?si=bjgdDAwxjb2DrDIk",
      "https://youtu.be/8Ctsaa14zM4?si=7mrTVMNjgjliw_An",
    ] 
  ),
  Song(
    title: "TODA LA NOCHE SIN PARAR",
    text: """
CANCIÓN: TODA LA NOCHE SIN PARAR - MSM
TONALIDAD: Bm (Original Cm)
TIEMPO: 150bpm

Intro: Bm - A - F#m - G
     Bm7                  Dmaj7 
//Toda la noche sin parar
       A                   F#m7
Cantando alabanzas al Señor
       G                        Em7
Diciendo de su gloria y majestad
           F#          E/F#
El es el Rey//

Coro:
     Bm
//Toda la noche sin parar
       A 
Cantando alabanzas al Señor
       G                        Em
Diciendo de su gloria y majestad
           F#
El es el Rey//
        Bm
De Israel
""",
    tonalidad: "Bm",
    tiempo: 150,
     
    multitrackLink: "",  
    youtubeLink: "https://youtu.be/NFweJ-9tMaI?si=aACeo_EvOs2LuJJf",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/cJZktebrquk?si=ITdkGaHm4L6MU20M",
      "https://youtu.be/K9sMjagWW50?si=PHslO1nEC_5myOA1",
    ],
    pianoLink: [
      "https://youtu.be/C2IVmKceDsc?si=oA3UlMuTM7pM_O_U",
      "https://youtu.be/OBVg5VniKcA?si=ET7PT0EixMOtJn-P",
    ],
    bassLink: [
      "https://youtu.be/J9kkFSsyZi8?si=-bgsfSd91Vo3qK_Z",
    ],
    drumsLink: [
      "https://youtu.be/_LAWgUr04D0?si=XxbZ1APOLNDcSUnI",
      "https://youtu.be/njgbYuvqh4g?si=OAx28fiT7M3d8tjo",
    ] 
  ),
  Song(
    title: "TÚ HABITAS",
    text: """
CANCIÓN: Tú habitas
TONALIDAD: Em
TIEMPO: 149bpm

INTRO: // Em - C - D - Em //
    Em          C           
//Tú eres Dios, eres Rey, 
D                Em
  eres Grande y temible
Em        C      D  
eres Luz, el amor 
                  Em    C - D
eres Cristo el Señor// 

PRE-CORO
        C               D      
//Tú habitas en las alabanzas 
         Em
  de tu pueblo
         C         D          Em
y en la hermosura de tu Santidad//

CORO:
         G      D     Em
Tú eres Santo, Santo, Santo
 C D     Em
Hijo de Dios...
         G      D      Em
Tu eres Digno, Digno, Digno
   C   D    Em 
Altísimo Señor
""",
    tonalidad: "Em",
    tiempo: 149,
    youtubeLink: "https://youtu.be/JZClilVNVrA",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/XJUBR4xOBlQ?si=jA4HXkye0pvZT2LI",
    ],
    guitarLink: [
      "https://youtu.be/aIlz5p6Gupk",
    ],
    pianoLink: [
      "https://youtu.be/d24N_wAXV6U",
      "https://youtu.be/xaSfrgaTvEw",
    ],
    bassLink: [
      "https://youtu.be/iNSLb1wnf9c",
      "https://youtu.be/r1QorQpUl-o",

    ],
    drumsLink: [
      "https://youtu.be/D8ENxnGABx8",
      "https://youtu.be/49AOeNFs31Y",

    ] 
  ),
  Song(
    title: "TÚ Y YO",
    text: """
CANCIÓN: Tu y Yo - Marcos Witt
TONALIDAD: Cm
TIEMPO: 143bpm

INTRO: PIANO
Cm                          Bb 
   Dios está llamando a la guerra 
 Cm                             Bb 
   nos está impulsando hacia afuera 
Fm                   Cm 
   acudiremos al llamado del Señor 
Fm                       G 
   tomaremos las armas que Él nos preparó  

CORO
Cm Bb Cm  Ab7 
Tú y  yo     somos un pueblo 
Cm Bb Cm  Ab7 
Tú y  yo     preparado 
Bb                      Cm 
para mostrar las grandezas del Señor 
Bb                       Cm/G  
  para tomar la tierra que Él 
           G  
  nos entregó.
""",
    tonalidad: "Cm",
    tiempo: 143,
    youtubeLink: "https://youtu.be/uR2ZABTfxQw?t=312",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/ILHiy1fvpmI?si=QkhFUDGuyLRpHESk",
    ],
    guitarLink: [
      "https://youtu.be/V61sPnug7yE?si=Vp5UlXruP-8KJ9EA",
      "https://youtu.be/ogf6EA68tGo?si=-eFebjZor7-NnvXo",
      "https://youtu.be/V61sPnug7yE?si=R5eNb9cq5peB_UfD",
    ],
    pianoLink: [
      "https://youtu.be/UZ7FVCh3rhM?si=Wx_X9fty4dCWdKJ8",
      "https://youtu.be/VI2Nar7HW9E?si=qS5KRmRXFmRN5j4n",
    ],
    bassLink: [
      "https://youtu.be/sBOYnJi2tIs?si=S8D1SnX70tIzseQs",
      "https://youtu.be/tJrE_2nZ5CI?si=V4ZAWMW28Cv1qBGg",
    ],
    drumsLink: [
      "https://youtu.be/0PClJR4z1ec?si=q_GI8NX8bOQWUjyG",
      "https://youtu.be/dCBP989zonw?si=LXQfmSYeM5hb95xY",
    ] 
  ),
  Song(
    title: "TU MANO ME SOSTIENE",
    text: """
CANCIÓN: Tu mano me sostiene - JAC
TONALIDAD: G
TIEMPO: 101bpm

INTRO: G - Am7 - D - G - Am7 (x4)

VERSO
               G
Tu mano me sostiene,
                 Am7
Tu espíritu me alienta
                D
y siempre en victoria
            G - Am7
Tu me llevaras

CORO
     Dm                       Am
Vivo solo para Cristo y nadie más
           C                  D
Solo en Jesús yo encontré la paz
       Dm                      Am
Él me llena de su espíritu de amor
              C                   D
siempre cantaré soy mas que vencedor.
    
""",
    tonalidad: "G",
    tiempo: 101,

    youtubeLink: "https://youtu.be/ftD0HEPTILI",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/1iwPDqHZuBA",
      "https://youtu.be/ViASJgxkwXc",
      "https://youtu.be/cMHq0Zlw2wY",
    ],
    pianoLink: [
      "https://youtu.be/R1X5CDssjGM",
      "https://youtu.be/LKfevtZmbHo",
    ],
    bassLink: [
      "https://youtu.be/YZC8rlr7XSY",
      "https://youtu.be/cC-c9kjaDzM",
      "https://youtu.be/c-UsjOFyd1k",
    ],
    drumsLink: [
      "https://youtu.be/RRkk4FPiDNI",
      "https://youtu.be/G_vZOaS_Ak8",
      "https://youtu.be/M32afhyHies",
    ] 
  ), 
  Song(
title: "QUEREMOS VER",
text: """
CANCIÓN: Queremos ver - Carlos Arzola
TONALIDAD: G
TIEMPO: 158bpm

INTRO: // G D Em C //
G              D           Em
  Queremos a Cristo proclamar
           C             G
como un estandarte levantar
             D           Em
que toda la gente pueda ver
                C            
que el es el camino al Cielo

CORO:
G                D             Em           
  //Queremos ver, queremos ver
        C          G
a Jesucristo como Rey//
       D              Em
Paso a paso hacia el frente
        D        Em
poco a poco a ganar
           D            Em
con la oración las fortalezas
       C                
todas caen todas caen y caen y caen      
      *vuelve al intro*
y caen

""",
    tonalidad: "G",
    tiempo: 158,
    youtubeLink: "https://youtu.be/IUNQbC_XxR4?si=0G0YbupPgyBWsgWc",
    instrument: 1,
    guitarLink: [
      "https://youtu.be/lMfzKGwmaJA",
      "https://youtu.be/ORVIpVLq37g",
      "https://youtu.be/HjOhXCURG1E",
    ],
    pianoLink: [
      "https://youtu.be/3CweeSwpyM4",
      "https://youtu.be/AIDDldZbzSQ",
      ],
    bassLink: [
      "https://youtu.be/ESerZ0gYHF4",
    ],
    drumsLink: [
      "https://youtu.be/gObdIWsee3I",
      "https://youtu.be/hyWnhiWTjwM",
    ] 
  ),
  Song(
    title: "QUIEN QUIEN",
    text: """
CANCIÓN: Quien quien quien como Jehová
TONALIDAD: Em
TIEMPO: 144bpm
    Em                              
// Quien quien quien como Jehová 
        Bm                 Em
que con su poder el mar abrió// 
  Am                      Em
Oirán las naciones lo que hiso
       Am                     Em
Temblarán al saber de sus prodigios
                  Em
Su pueblo le alabará con panderos danzarán
        Bm                      Em
//Y  dirán quien quien como Jehová//  

INICIO
       Em                D      
//Cantaré al señor por siempre 
    C         D      Em   
su diestra es todo poder//

VERSO 1
                D D       
//Hecho a la mar    
               Em
los que perseguían 
                D D   
jinete y caballo     
           Em
hecho a la mar//

FINAL
    D        C      Am      
Hecho a la  mar los carros 
        Bm    Bm  Bm
del faraón    hey hey 
  Em  D    C     D    Em
LA LA LA LA LA LA LA LA LA 

VERSO 2
                 D D              Em
Mi padre es Dios    y yo le alabo 
                D D               Em
Mi padre es Dios    y le alabaré
                D D              Em
Mi padre es Dios    y yo le exalto 
                D D              Em
Mi padre es Dios    y le exaltaré
*FINAL*
""",
    tonalidad: "Em",
    tiempo: 144,
    youtubeLink: "https://youtu.be/eHrtkOGw17M?si=fDX_oedRk_dbjKbM",
    instrument: 1,
  ),
  Song(
    title: "REMOLINEANDO",
    text: """
CANCIÓN: Remolineando
TONALIDAD: Bm
TIEMPO: 153bpm

INTRO: // Bm - A //
VERSO 1
            Bm
hay muchas formas de alabar tu nombre
          A           Bm
y de exaltarte oh Jehová
            G      A         Bm
hay muchas formas de magnificarte
       G    A       Bm
pero ahora lo haré así

CORO:
Bm                         
remolineando, remolineando, 
       A       Bm
celebraré a Jehová
       Bm                                
remolineando, remolineando,
          G      A         Bm
 yo cantaré con gozo a Jehová
  Bm           A           Bm
//lalalalala lalalala lalalala//

VERSO 2
Bm                          
sacó mi vida del anonimato, 
          A             Bm 
me dio corona y vestido real
            G       A          Bm
asi es Jehová que exalta al pequeño
              G A               Bm
por causa de él yo me hare mas vil//

CORO
""",
    tonalidad: "Bm",
    tiempo: 153,
    youtubeLink: "https://youtu.be/QMNOtZQKGS4",
    instrument: 1,
  ),
  Song(
    title: "SI TUVIERAS FE",
    text: """
CANCIÓN: Si tuvieras fe
TIEMPO: 105bpm
TONALIDAD: Am
              Am     
//Si tuvieras fé 
            F           E
como un granito de mostaza,
E              Am
eso dice el Señor//

PRE-CORO
           Dm            Am  
//Tu le dirías a esa montaña, 
         E        Am
  muevanse, muevanse//

CORO
                       E   
//Esas montaña se moverán, 
                      Am
  se moverán, se moverán//
""",
    tonalidad: "Am",
    tiempo: 105,
  ),
  Song(
    title: "VIENE YA",
    text: """
CANCIÓN: Viene ya
TONALIDAD: Am
TIEMPO: 150bpm

Intro: Am - F - C - G x 4

VERSO:
Am       F          C   
   Preparemos el camino 
           G     Am F C G
   Cristo viene ya
Am       F          C   
   Anunciemos su venida 
        G     Am F C G
   en todo lugar
Am        F              C   
   Que se abran hoy las puertas 
           G    Am F C G
   el rey viene ya
Am       F        C       
   Volveremos adorarle 
           G     Am F C G
   por la eternidad.

CORO:
Am G  F       C      G         Am
Viene  ya mi amado, pronto le veré
Am G  F       C      G         Am
Viene  ya mi amado, pronto volverá
  Am   G F          C     
Y voy cantando, gritando, 
      G           Am
celebrando su victoria
Am G  F       C      G         Am
Viene  ya mi amado, Cristo viene ya

PUENTE:
Am       F   C   G  Am F C G
   Volveremos cantando
Am       F   C   G  Am F C G
   Volveremos saltando
Am       F   C   G  Am F C G
   Volveremos con gozo
Am   F   C   G   Am
   Volveremos gritando

SOLO : Am F C G

FINAL
  Am   G F          C      
Y voy cantando, gritando, 
      G           Am
celebrando su victoria
Am G  F       C    
Viene ya, mi Amado 
  G         //Am F C G//
¡Cristo viene ya!
""",
    tonalidad: "Am",
    tiempo: 150,
    multitrackLink: "https://youtu.be/fOcb7qDPQps",  
    youtubeLink: "https://youtu.be/M910fiIPMTs",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/TzAX7jQUsEw?si=GWh4p6LkbvBkxZbD",
    ],
    guitarLink: [
      "https://youtu.be/Nd8S-AyMxrg",
      "https://youtu.be/jTrDmUdvjL0",
      "https://youtu.be/TR0IHTO4bXY",
      "https://youtu.be/3pedhZH6buA",
      "https://youtu.be/OgTyIvNu300",
      "https://youtu.be/vB8T9xZIFyg",
    ],
    pianoLink: [
      "https://youtu.be/KsIW0DXHl_E",
      "https://youtu.be/BL2zpzHDTWM",
      "https://youtu.be/NIlszkaa0Yk",
      "https://youtu.be/-63Yob7reqc",
      "https://youtu.be/K5jan9Hl-ZY",
    ],
    bassLink: [
      "https://youtu.be/wmhwe_4Ytrw",
      "https://youtu.be/EFBLTK2lCkc",
      "https://youtu.be/NGSoh0iMVvs",
    ],
    drumsLink: [
      "https://youtu.be/INdmcOHmtiI",
      "https://youtu.be/_NLSGeSxCFA",
      "https://youtu.be/Qaa9Fzoxdrk",
      "https://youtu.be/Aw66lBjfXzI",
    ] 
  ),
  
Song(
    title: "POPURRÍ D",
    text: """
        D
//Alabaré, Alabaré
  Alabaré, Alabaré
        A         D
  Alabaré a mi señor //


            D              A
Cuando los santos marchen ya 
         A7            D
hacia la patria celestial
           D7            G 
Señor yo quiero estar allá
            D      A      D 
cuando los santos marchen ya.


  D
//A que tú no sabes
                        A Asus4 A
Lo que en la iglesia pasó,
         A Asus4      D
Lo que pasó,Lo que pasó //

   G
//Fue el Espíritu Santo,
   D
  Fue el Espíritu Santo,
   A
  Fue el Espíritu Santo,
              G        A    D
  sobre la iglesia se derramó //


     D
//Oh, qué contento estoy//
      G                D
Si Jesús viene en las nubes
           A          D
con mi hermano yo me voy.
        G           D
// Que bueno es cantar
        A        D
Cuando hay gratitud
     G            D
estaré cantando alegre 
       A           D
por toda la eternidad//
 

              D                   A
Solamente en Cristo, solamente en Él
        Asus4 A              D   D7
La salvación se encuentra en Él
             G                 D
No hay otro nombre dado a los hombres
              A                   D
Solamente en Cristo, solamente en Él


          D
// Una mirada de Fé
Una mirada al Señor
           A                   D  D7
Es la que puede salvar al pecador //
            G
//Y si tu vienes a Cristo Jesús
              D
Él te perdonará
                      A
Porque una mirada de Fe
      G        A       D
Es aquel que puede salvar//


              D
//Éste es el Cristo
que yo predico         
                       A
y no me canso de predicar
Él sana a los enfermos
reprende a los demonios
   G       A      D
y calma la tempestad//
         G           A        D
Si tu supieras quien es el Señor
        G        A      D
arrepentido vendrias a él
         D7             C  D     G
su santa sangre en la cruz derramó
      D             A       D
para salvar al más vil pecador


        D
//Yo no sé lo que tú has venido
         A               D
Pero yo vine a alabar a Dios //
    G        D
Aleluya, aleluya
     A                D
hoy vine a alabar a Dios

                    A A
//Pero que felicidad
                  D D
Pero que felicidad
    G                D
Cantemos todos en coro 
          A            D
a nuestro padre celestial//
""",
    tonalidad: "D",
    tiempo: 100,
  ),
Song(
    title: "POPURRÍ Dm",
    text: """
             Dm 
//Cuando el pueblo del señor 
                      C
alaba a Dios suceden cosas
                     Dm
Suceden cosas maravillosas//

           Bb          F
//Hay sanidad, liberación
    C                         Dm
Se siente la presencia del señor//


         Dm                        C
//Jerusalén Jerusalén que bonita eres
                          Dm   D7
calles de oro, mar de cristal//
 
            Bb              F        
//Por esas calles yo voy a caminar
          C                D
calles de oro, mar de cristal//


            Dm                    C
//En el principio el espíritu de Dios
                   Dm
se movia sobre las aguas//
        Bb              F
//Pero ahora se está moviendo 
       C          Dm
dentro de mi corazón//


           Dm                     C
//Una cosa sé, que habiendo sido ciego 
                          Dm    D7
ahora veo la luz de mi Señor//
           Bb                 F
//La luz divina que me dio Jesús 
               C               Dm
cuando por la fe yo vi al salvador//
  Dm                           C
//Y los fariceos decian sin cesar                               
ese hombre es pecador, 
                   Dm    D7
ese hombre es pecador//
             Bb           F                  
//Si es pecador yo no lo sé, 
              C              Dm
lo único que sé, que él me sanó//


         Dm
Los que esperan,
                        C 
los que esperan en Jehová
Los que esperan,
                        Dm
los que esperan en Jehová
           Bm                F
//Como las águilas, como las águilas, 
    C            Dm
sus alas levantarán//

      C                Dm
Correrán y no se cansarán
       C               Dm
Caminarán, no se fatigarán
            Bb 
//Nuevas fuerzas tendrán, 
          F
Nuevas fuerzas tendrán
           C
Los que esperan, 
                       Dm
los que esperan en Jehová//


               Dm
//Cristo es la Peña de Horeb 
             C
que esta brotando 
                            Dm
agua de vida saludable para ti//

          Bb              
//Ven a beberla que es 
                  F
mas dulce que la miel
             C 
Refresca el alma 
                 Dm
refresca todo tu ser//
""",
    tonalidad: "Dm",
    tiempo: 100,
  ),
  Song(
    title: "POPURRÍ HUAYNOS",
    text: """
   
   Dm
//Amémonos hermanos 
    C        Dm
de todo corazón//
  F
//una familia somos 
    C             Dm
de nuestro padre Dios//


  Dm               C Dm
//Ama como Dios te ama//
  F                    C Dm
//Perdona como Dios perdona//


      Dm     C      Dm
//Sin mirar hacia atrás
     Dm    C   Dm 
sin volver a pecar
       F    
vamos pues con Jesús
              C Dm
al lugar celestial//


  Dm               C           Dm
//Cuando estaba yo lejos del señor//
  F                             C   Dm
//cayó una buena semilla en mi corazón//
  Dm              C              Dm
//esa semilla fue la palabra de Dios//
   F                 
//Quien cambio mi vida
          C        Dm 
para la gloria de Dios//


  Dm 
//En las nubes el vendrá 
          C    Dm
en aquel dia final//
   F    
//Cuando Cristo volverá 
                C    Dm
por aquellos que el amó//

  Dm
//El sol se oscurecerá 
                 C   Dm
al ver la gente llorará//
   F   
//Mas los hijos del señor
                C   Dm
llenos de gozo estarán//


Dm                  C      Dm
No importa hermanos sufrir aqui
Dm                  C      Dm
no importa hermnos llorar aqui
F                       C   Dm
allá en el cielo ya no sufrirás
F                       C   Dm
allá en el cielo ya no llorarás

Dm              C    Dm
Todo lo hermoso recibirás
Dm              C    Dm
Todo lo hermoso recibirás
F                   C       Dm
No importa hermanos sufrir aqui
F                   C      Dm
no importa hermnos llorar aqui
""",
    tonalidad: "Dm",
    tiempo: 90,
  ),
  Song(
    title: "POPURRÍ MI JESÚS",
    text: """
1. Mi Jesús yo te amo
Intro charango: Bm D Bm A  G
                Bm D A G Em

      G         D Em
Mi Jesús yo te amo
      G         D Em
Mi Jesús yo te adoro //
          D          G
Como las águilas volaré
           D        Em
Como corderito saltaré //

CORO:
             D          G
Cantando adorando te alabaré
             D        Em
Y dando vueltas me gozaré
             D          G
Saltando danzando te alabaré
         Bm            Em
Y dando vueltas me gozaré

2. SI ME DICES A DODNE VAS
INTRO: Las mismas notas de la canción

      Em             G
Si me dicen a donde vas
    D              Em
Yo voy alabar al Señor x2

PRE-CORO:
   G             D
//Como lo vas hacer
Bm       D     Em
Como lo vas hacer//

CORO:
         G               D
//Voy a Cantar voy a Danzar
      Bm          Em
En Espíritu y en Verdad //

3. ALELUYA, ALELUYA
INTRO: Las mismas notas de la canción

C
Aleluya Aleluya,
G
Aleluya Aleluya,
D        Bm     D      Em
Aleluya gloria sea a Dios

Verso 2
C
Yo te alabo yo te adoro,
G
Con el corazón te canto
D              Bm  D   Em
Y por siempre, te alabaré

CORO:
            G
//Por que yo te quiero
      D
Yo te amo a ti,
Bm    D     G
Mi Papito Dios.
        G
Por que yo te quiero,
      D
Yo te amo a ti,
Bm      D   Em
Papito Jehová//

4. QUE MAS PUEDO OFRECERTE
Em         C
//Que más puedo ofrecerte,
D             G
Solamente mi corazón// 

PRE-CORO:
    G 
Solamente mi corazón
D                     Em
puedo ofrecerte oh Señor
   G 
Solamente mi corazón
D               Bm    Em
puedo ofrecerte oh Señor.

CORO:
       G
//Mi vida, mi vida
         C         G
Sólo es tuyo oh SEÑOR
     G
Mi vida, mi vida
         Bm   D    Em
Sólo es tuyo oh SEÑOR//

5. CON ALEGRÍA

VERSO:1
    Em      D        G
Con alegría yo cantaré,
   Bm      D      Em
Alabanzas a mi Señor//

CORO:
            G            D
Como el cordero yo saltaré,
          Bm        D   Em
En su presencia me gozaré//

VERSO2:
   Em                  D   G
//Tu fuego está en mi corazón
     Bm   D       Em
Renovando todo mi ser//

6. ARRIBA LAS MANOS

Em          D
Arriba las manos
Bm           D     Em
Dando palmas al Señor// 

CORO:
G
Cantando, Danzando
        D           G
Te alabaré Señor Jesús.
G
Cantando, Danzando
           Bm   D     Em
Te alabaré Señor Jesús
""",
    tonalidad: "G",
    tiempo: 155,
  ),
];
final List<Song> cancionesSimplificadas1 = [
  Song(
    title: "AGUAS PROFUNDAS",
    text: "Ven sobre mí como lluvia, haz las aguas subir en este lugar, libera tu río sin medida y ven a tus aguas agitar, pues yo quiero nadar, quiero nadar en tu río, quiero beber, quiero beber de tus aguas; yo sé que hay más de ti, Señor, tiene que haber más; existen aguas a los tobillos, existen aguas a las rodillas, existen aguas a los lomos, pero hay aguas profundas, ¡yo sé!",
    tonalidad: "Am",
    tiempo:0,
    status: 2,
  ),
  Song(
    title: "ALABA",
    text: "Que toda la creación alabe a Dios, alabe a Dios; te alabo en el valle, te alabo en el monte, te alabo en el día, te alabo en la noche, te alabo en el medio, estando rodeado, porque cuando alabo Tú estás a mi lado; mientras tenga aliento mi alma canta y alaba a Dios, mi corazón alaba a Dios, te alabo al sentirlo y aun cuando no, te alabo y sé que estás en control; es más que un sonido, es adoración, oh-oh-oh, y cuando alabamos caerá Jericó; mientras tenga aliento mi alma canta y alaba a Dios, mi corazón, mi alma alaba a Dios; no me detengo, mi Dios vivo está, ¿cómo me voy a callar? mi alma alaba a Dios; alabo al que reina, alabo al Señor, alabo a aquel que la tumba venció, alabo al que es bueno, alabo al que es fiel, le alabo porque no hay otro como Él.",
    tonalidad: "A",
    tiempo:0,
    status: 2,
  ),
  Song(
    title: "ANTE TI CON GOZO",
    text: "Me gozaré en tu presencia Jehová con todas mis fuerzas gritaré, hey! Me gozaré en tu presencia Jehová con todas mis fuerzas gritaré. Ante ti con gozo palmiaré con alegre danza celebraré saltare y me gozare",
    tonalidad: "Bm",
    tiempo:0,
    status: 1,
  ),
  Song(
    title: "BUENO ES ALABAR",
    text: "Bueno es alabarte Señor ¡Tu nombre! Darte gloria honra y honor ¡Por siempre! Bueno es alabarte Señor y gozarme en tu poder. Porque grande eres tú, grandes son tus obras. Porque grande eres tú, grande es tu amor, grande son tus obras.",
    status: 1,
    tonalidad: "G",
    tiempo:0,
  ),
  Song(
    title: "CAMBIARÉ MI TRISTEZA",
    text: "Cambiare mi tristeza, cambiare mi vergüenza. Los entregaré, por el gozo de Dios. Cambiare mi dolor y mi enfermedad. Los entregaré por el gozo de Dios. Si Señor, Si, Si Señor. Estando atribulado, pero nunca derrotado. Y perseguido este hoy. Maldiciones no me afectan, pues yo sé a quien voy. En su gozo, fuerte soy. Aunque triste en la noche yo esté, gozo viene en la mañana.",
    status: 2,
    tonalidad: "A",
    tiempo:0,
  ),
  Song(
    title: "CON MI DIOS",
    text: "Con mi Dios yo saltaré los muros, con mi Dios ejércitos derribaré. El adiestra mis manos para la batalla, puedo tomar con mis manos el arco de bronce. Él es escudo, la roca mía, Él es la fuerza de mi salvación, mi alto refugio, mi fortaleza, Él es, mi libertador.",
    status: 2,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "DANZANDO",
    text: "Tu palabra dice aunque pase por el fuego no me quemaré y si paso por las aguas, no me ahogaré. Aunque haya oscuridad, con fe, caminaré, pues tú siempre vas conmigo. Tu palabra dice no hay justo que Tú hayas desamparado. Eres pan para el hambriento y necesitado. En mi mesa nunca, nunca ha faltado. Tú provees y no has fallado. Yo no temeré, tu promesa es fiel. Tu yugo es fácil, ligera es tu carga. Te entrego mi vida y mi alabanza. Mi escudo, mi fuerza, mi seguridad. Con Cristo camino y estoy danzando en cada temporada. Danzando en cada temporada. Tu palabra dice que Tú oyes el clamor del quebrantado. Por tu llaga en la cruz, fuimos sanados. Sobre toda enfermedad, Tú has ganado y mi vida está en tu mano. Tu palabra dice que tu muerte en la cruz fue por salvarnos, que perdonas y redimes del pecado y en las nubes, seremos arrebatados. Cara a cara, te veremos. Sigo danzando, glorificando en cada temporada, tú sigues obrando. Aunque ande en el valle de sombra, danzo, danzo, danzo, danzo. No se apaga, no se apagará este ritmo. Aunque venga contra mí el enemigo, tus promesas siempre van conmigo. Danzo, danzo, danzo, danzo. En ti yo confío, en ti yo confío. En ti yo confío, en ti yo confío. En ti yo confío, en ti yo confío.",
    status:2,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "DESPIERTA",
    text: "Como en el pasado volverán los que rescataste a ti regresarán, llenos de alegría cantarán. El llanto y el dolor desaparecerán. Por eso yo no temeré lo que el hombre pueda hacer. Yo confiaré en mi hacedor que extendió el cielo y el mar. Despierta, Señor, despiértate con tu fuerza, con tu brazo poderoso. Como en el tiempo antiguo, con tu soplo secaste el mar, e hiciste un camino. Tú rompiste mi pasado, la libertad es mi destino. Oh, oh, oh, oh, oh. Sé que todo lo puedes. Oh, oh, oh, oh, oh. Nada puede detenerte.",
    status: 1,
    tonalidad: "Dm",
    tiempo:0,
  ),
  Song(
    title: "DIOS NO ESTÁ MUERTO",
    text: "Que tu amor descienda con poder, revolución, que traiga avivamiento en todo lugar. Solo en ti yo soy libre y a este mundo venceré. Mi Dios no está muerto, el vivo está. Él venció la muerte y vive para siempre. Mi Dios no está muerto, el vivo está. Él venció la muerte y vive para siempre. Vive, vive, vive para siempre. Que las tinieblas huyan ante ti. Avívame y dame fortaleza para seguir. Desciende hoy con fuego Dios. La creación temblará al oír tu voz.",
    status: 2,
    tonalidad: "G#m",
    tiempo:0,
  ),
  Song(
    title: "EL EJÉRCITO DE DIOS",
    text: "Porque grande es el Señor y para siempre es su misericordia. El ejército de Dios marchando está contra todo principado y potestad. El ejército de Dios marchando está.",
    status: 2,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "EL SEÑOR ES MI REY",
    text: "El Señor es mi rey, mi todo el Señor es mi luz, mi rey el que me hace vibrar de gozo el que guía mis pasos el que extiende sus brazos el creador de los cielos",
    status: 1,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "EL SEÑOR MARCHANDO VA",
    text: "El Señor marchando va y su pueblo junto a él está. Su gloria en nuestras vidas brillará. Su victoria nos ha dado ya y su brazo nos fortalecerá. Lucharé hasta la tierra conquistar. En mi vida el capitán es Cristo, marcharemos ante su presencia. No hay arma que nos pueda derrotar.",
    status: 1,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "ERES SEÑOR VENCEDOR",
    text: "Eres Señor Vencedor, el Invencible. Eres Campeón, Ganador en Batalla. Eres mi Rey y mi Dios, el que cuida a su pueblo. Por eso yo te canto y te alabo, porque sé que me proteges, porque estoy de tu lado.",
    status: 2,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "ERES TODOPODEROSO",
    text: "La única Razón de mi adoración Eres tú mi Jesús El único motivo para vivir Eres tú Mi Señor Mi única verdad está en Ti Eres mi luz y mi salvación Mi único amor eres Tú, Señor Y por siempre te alabaré Tu Eres Todo poderoso Eres Grande y Majestuoso Eres Fuerte e Invencible Y no hay nadie como Tú",
    status: 2,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "ERES TÚ",
    text: "Jesús, tú eres el amigo que me ama. Jesús, tú eres la esperanza de mi vida. Eres, eres, eres tú. Eres, eres tú. Jesús, tú eres el camino y la vida. Jesús, tú eres salvación y alegría. Eres, eres, eres tú. Eres, eres tú. Tú eres Rey, eres Señor, y en una cruz fuiste a vencer. Engrandecido eres Dios, te levantaste con poder.",
    status: 1,
    tonalidad: "E",
    tiempo:0,
  ),
  Song(
    title: "ES TIEMPO",
    text:"Amor inexplicable Tu vida diste en la cruz Tuyo soy por siempre En tu misericordia Me diste vida, diste amor Tu gran amor Es tiempo de decidir por quien vivo Te seguiré, mi alabanza te daré Por ti, por ti lo entrego todo Sólo a ti mi alabanza doy Toda mi alabanza doy Por ti, por ti es por quien vivo Te alabaré con todo lo que soy Toda mi alabanza doy Tuyo soy Señor Vivo para darte Gloria, oh Dios Gloria y honor.",
    status: 1,
    tonalidad: "A",
    tiempo:0,
  ),
  Song(
    title: "FIESTA",
    text: "Lo que se canta en el cielo cantamos en la tierra al que se adora en el cielo adoramos en la tierra lo que se canta en el cielo cantamos en la tierra al que se adora en el cielo adoramos en la tierra al Santo digno al Cordero que vive para siempre hacemos fiesta hoy hacemos una fiesta unidos hoy danzamos con gozo celebramos oh uh oh uh oh fiesta hoy hacemos una fiesta en la tierra cantamos juntos gritamos oh uh oh uh oh hacemos fiesta hacemos fiesta fiesta fiesta hacemos fiesta fiesta hacemos fiesta fiesta fiesta fiesta",
    status: 2,
    tonalidad: "Cm",
    tiempo:0,
  ),
  Song(
    title: "GRANDE Y FUERTE",
    text: "Grande y fuerte es nuestro Dios. Vestido en majestad, coronado con poder, digno de toda la adoración. Vestido en majestad, coronado con poder, toda gloria y honra sea para ti.",
    status: 2,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "GRACIA SUBLIME",
    text: "Quién rompe el poder del pecado con un amor fuerte y poderoso, el Rey de gloria y de majestad, el que conmueve el mundo con su estruendo y nos asombra con sus maravillas; gracia sublime es su amor perfecto, porque tomó nuestro lugar y cargó nuestra cruz, dio su vida allí y ahora somos libres, Jesús a ti adoramos por lo que hiciste en nosotros; tú pusiste en orden todo el caos, nos adoptaste como tus hijos, gobiernas con justicia y resplandeces con belleza, Rey de gloria y de majestad, digno es el Cordero de Dios, digno es el Rey que venció la muerte",
    status: 1,
    tonalidad: "A",
    tiempo:0,
  ),
  Song(
    title: "HAS CAMBIADO - ADONAI",
    text: "Has cambiado mi lamento en baile, me ceñiste todo de alegría, has cambiado mi lamento en baile, me ceñiste todo de alegría, por tanto a ti cantaré, gloria mía, gloria mía, sólo a ti danzaré, gloria mía, gloria mía, oh Adonai, oh Adonai, Dios del universo, Señor de la creación, los cielos cuentan tu gloria, tus hijos hoy te adoran, por todas tus maravillas, Adonai, los cielos cuentan tu gloria, tus hijos hoy te adoran, por todas tus maravillas, Adonai.",
    status: 2,
    tonalidad: "C",
    tiempo:0,
  ),
  Song(
    title: "HAY LIBERTAD",
    text: "Hoy puedo danzar con libertad porque soy su hijo, porque soy su hijo. Hoy puedo danzar con libertad porque soy amado, porque soy amado. Podemos sentir tu gozo, podemos sentir tu río. Hay sanidad en las aguas, queremos danzar. Hay libertad en la casa de Dios, hay libertad en la casa de Dios. Hay libertad, hay libertad. Hay libertad en la casa. Hay libertad al dan zar. Puedo danzar en la casa de Dios, puedo danzar en la casa de Dios. Puedo danzar y disfrutar. Que somos libres, somos libres. Por tu sangre libre soy. Libre soy.",
    status: 2,
    tonalidad: "Dm",
    tiempo:0,
  ),
  Song(
    title: "HOY ES TIEMPO",
    text: "Hoy es tiempo de celebrar, todos unidos vamos a cantar, tomados de las manos, vamos a danzar. Danzaré, danzaré, me gozaré, me gozaré, con gritos de júbilo celebraré.",
    status: 1,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "HOSANNA",
    text: "Levantamos un clamor Por sanidad y redención Muéstranos lo que tú ves Los secretos de tu corazón Un pueblo unido pide hoy Tu libertad y salvación Ármanos con tu valor Lo que deseamos es revolución Que el cielo se parta en dos Inúndanos En el desierto broten ríos Vida sopla hoy Hosanna al rey de salvación Hosanna al Dios Altísimo Hosanna Jesucristo, Jesucristo es rey Hosanna al rey de salvación Hosanna al Dios Altísimo Hosanna Jesucristo, Jesucristo es rey",
    status: 2,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "INCREÍBLE",
    text: "Poderoso, invencible, admirable, grande y fuerte Dios, Rey de Reyes, asombroso, incomparable. Eres increible, todopoderoso, grande, eres increible, venciste las tinieblas, Cristo exaltado estás Increíble, invencible, mi Dios solo tú, solo tú. Tú eres increíble, invencible, mi Dios solo tú, solo tú",
    status: 2,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "JEHOVÁ ES MI FORTALEZA",
    text: "Jehová es mi fortaleza, mi Dios mi salvador, él es mi escudo mi protector, Él me librará de la tormenta, con sus lazos de amor me sostendrá. Poderoso Dios grande en batalla, si tú estás conmigo no temeré",
    status: 1,
    tonalidad: "Dm",
    tiempo:0,
  ),
  Song(
    title: "JEHOVÁ ES MI GUERRERO",
    text: "Jehová es mi guerrero, oh, oh, oh. Jehová es mi guerrero, oh, oh, oh. Con mi alabanza pelearé, no es mi guerra sino la de Dios. Danza y pandero yo daré, no es mi guerra sino la de Dios. Címbalo y trompeta sonaré, no es mi guerra sino la de Dios. Con fuerte y alta voz yo gritaré. ",
    status: 1,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "JEHOVÁ ES MI LUZ",
    text: "Jehová es mi luz y mi salvación, Jehová es la fortaleza de mi vida, aunque un ejército acampé contra mí, no temerá mi corazón. No temeré, no temeré, aunque contra mí se levanten. Remolineando, remolineando, danzando, danzando, celebrando la victoria del Señor.",
    status: 1,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "LA CASA DE DIOS",
    text: "Mejor es un día en la casa de Dios que mil años lejos de Él, prefiero un rincón en la casa de Dios que todo el palacio de un rey. Ven conmigo a la casa de Dios, celebraremos juntos su amor, haremos fiesta en honor de aquel que nos amó. Estando aquí en la casa de Dios, alegraremos su corazón, le brindaremos ofrendas de obediencia y amor, ¡en la casa de Dios! Arde mi alma, arde de amor por aquel que me dio la vida, por eso le anhela mi corazón, anhela de su compañía, anhela de su compañía.",
    status: 2,
    tonalidad: "D",
    tiempo:0,
  ),
  Song(
    title: "LA COSECHA",
    text: "Alza tus ojos y mira, la cosecha está lista, el tiempo ha llegado, la mies está madura. Esfuérzate y sé valiente, levántate y predica a todas las naciones que Cristo es la vida. Y será ah ah, llena la tierra de su gloria, se cubrirá ah ah, como las aguas cubren la mar.",
    status: 1,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "LEVÁNTATE",
    text: "Levántate, levántate Señor, que tus enemigos huyan delante de ti. Mas los justos se alegrarán, cantarán con regocijo, el Señor se ha levantado, ha triunfado con poder.",
    status: 1,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "LEVÁNTATE SEÑOR",
    text: "Levántate, levántate Señor, levántate, levántate Señor. Huyan delante de ti tus enemigos, se dispersan delante de ti todos aquellos que aborrecen tu presencia. Tu presencia reinará, sobre todo imperio, tu presencia reinará, gobernará sobre todo principado. Espíritu de temor, huye; Espíritu de maldad, huye. Espíritu de rencor, huye; Espíritu de división, huye. Espíritu de enfermedad, huye; Espíritu de rebelión, huye. Espíritu de inmoral, huye; Espíritu de oscuridad, huye. Espíritu de perversión, huye; Espíritu de ambición, huye. Espíritu de profanador, huye; Espíritu de vanidad, huye. Espíritu de murmuración, huye; Espíritu de contención, huye. Espíritu de hechicería, huye; Espíritu de mortandad, huye.",
    status: 1,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "LOS MUROS CAEN",
    text: "Los muros caen, los muros caen y con ellos las cadenas. Los muros caen, los muros caen, se derrumban las fortalezas. El Señor entregó en mis manos Jericó. Grita ¡Hey! Toca la trompeta.",
    status: 1,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "LOS MUROS CAERÁN",
    text: "Cuando le canto la tierra se estremece, los muros caerán. Cuando le adoro se rompen las cadenas, los muros caerán. Los muros caerán, los muros caerán, al sonar mi cántico caerán. Los muros caerán, los muros caerán, con gritos de júbilo caerán. Cuando yo danzo aumenta Dios mis fuerzas, los muros caerán. Cuando yo grito mis enemigos huyen, los muros caerán. Caen los muros, caen los muros. Saltando, saltando, los muros caerán; gritando, gritando, los muros caerán.",
    status: 2,
    tonalidad: "Cm",
    tiempo:0,
  ),
  Song(
    title: "MARAVILLOSO ES EL SEÑOR",
    text: "Maravilloso es el Señor Jesús, quien reina con poder, poder. El es mi Rey, Él es mi Rey y en su casa danzaré.",
    status: 1,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "ME GOZARÉ",
    text: "Cuando el Señor hiciere volver de la cautividad, seremos como los que sueñan. Mi boca llenará de risa y mis labios de alabanza; entonces las naciones dirán que grandes cosas ha hecho el Señor. Me gozaré, me gozaré, me gozaré en Jehová, pues ha llevado todo mi dolor y me ha hecho libre.",
    status: 2,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "MI DIOS ES GRANDE Y FUERTE",
    text: "Mi Dios es grande y fuerte y su palabra vence; sus enemigos tiemblan y huyen ante Él. Jesucristo es el Señor, mi Rey, y en su nombre hay poder para vencer.",
    status: 1,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "NO HAY TORMENTAS",
    text: "No hay tormentas que me puedan destruir, no hay gigante que me pueda detener. Por más grande sean mis problemas, tengo al vencedor en sus manos voy seguro y no me rendiré. Porque soy más que un vencedor en Cristo Jesús. Si Dios está conmigo, ¿quién contra mí? En sus brazos voy seguro, él me sostendrá.",
    status: 1,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "PODEROSO DE ISRAEL",
    text: "Y de noche cantaremos, celebrando su poder, con alegría de corazón, como el que va con la flauta al monte del Señor. Él es el Poderoso de Israel. Su voz se oirá, nadie lo detendrá. Y los ojos de los ciegos se abrirán, los oídos de los sordos oirán, el cojo saltará, y la lengua de los mudos cantará.",
    status: 1,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "TE ALABARÉ",
    text: "Eres tú la única razón de mi adoración, oh Jesús. Eres la esperanza que anhelé tener, oh Jesús. Confié en ti, me has ayudado; tu salvación me has regalado. Hoy hay gozo en mi corazón, con mi canto te alabaré. Te alabaré, te glor ificaré, te alabaré, mi buen Jesús. En todo tiempo te alabaré y en todo tiempo te adoraré.",
    status: 2,
    tonalidad: "B",
    tiempo:0,
  ),
  Song(
    title: "TÓMALO",
    text:"De todo lugar los perdidos vendrán en libertad a ti clamarán, llevaste la cruz, moriste y vivo estás, mi Dios, a ti mi vida te daré; enviaste a Jesús por mi salvación, por la eternidad en ti tengo perdón, busqué la verdad y te encontré a ti, mi Dios, a ti mi vida te daré; Jesús, por ti yo viviré, de ti nunca me avergonzaré, te doy todo lo que soy, toma, tómalo, toma, tómalo; eres el que vista al ciego das, brillas en la oscuridad, la salvación del mundo en tus manos está.",
    status: 1,
    tonalidad: "B",
    tiempo:0,
  ),
  Song(
    title: "TODA LA NOCHE SIN PARAR",
    text: "Toda la noche sin parar cantando alabanzas al Señor diciendo de su gloria y majestad Él es el Rey de Israel",
    status: 1,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "TÚ HABITAS",
    text: "Tú eres Dios, eres Rey, eres Grande y temible, eres Luz y Amor, Cristo el Señor. Habitas en las alabanzas de Tu pueblo y en la hermosura de Tu Santidad. El coro exalta Tu santidad y dignidad como el Hijo de Dios y Altísimo Señor.",
    status: 1,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "TÚ Y YO",
    text: "Dios está llamando a la guerra, impulsándonos a salir y a responder a Su llamado. Se nos anima a tomar las armas que Él nos ha preparado. El coro destaca que somos un pueblo preparado para manifestar las grandezas del Señor y tomar posesión de la tierra que Él nos ha entregado.",
    status: 1,
    tonalidad: "Cm",
    tiempo:0,
  ),
  Song(
    title: "TU MANO ME SOSTIENE",
    text: "Tu mano me sostiene y Tu espíritu me alienta, llevándome siempre en victoria. El coro expresa que se vive solo para Cristo, encontrando paz en Él y siendo llenado de su amor, proclamando con alegría que somos más que vencedores.",
    status: 1,
    tonalidad: "G",
    tiempo:0,
  ),
  Song(
    title: "QUEREMOS VER",
    text: "Queremos a Cristo proclamar como un estandarte levantar que toda la gente pueda ver que Él es el camino al Cielo, queremos ver, queremos ver a Jesucristo como Rey, paso a paso hacia el frente, poco a poco a ganar, con la oración las fortalezas todas caen todas caen y caen y caen.",
    status: 1,
    tonalidad: "G",
    tiempo:0,
  ),
  Song(
    title: "QUIEN QUIEN",
    text: "Quien quien quien como Jehová que con su poder el mar abrió, oirán las naciones lo que hizo, temblarán al saber de sus prodigios, su pueblo le alabará con panderos danzarán, y dirán quien quien como Jehová. Cantaré al Señor por siempre su diestra es todo poder. Hecho a la mar los que perseguían, jinete y caballo hecho a la mar. Hecho a la mar los carros del faraón hey hey, LA LA LA LA LA LA LA LA LA LA LA LA LA LA LA LA. Mi padre es Dios y yo le alabo, mi padre es Dios y le alabaré, mi padre es Dios y yo le exalto, mi padre es Dios y le exaltaré.",
    status: 1,
    tonalidad: "Em",
    tiempo:0,
  ),
  Song(
    title: "REMOLINEANDO",
    text: "hay muchas formas de alabar tu nombre y de exaltarte oh Jehová hay muchas formas de magnificarte pero ahora lo haré así remolineando, remolineando, celebraré a Jehová remolineando, remolineando, yo cantaré con gozo a Jehová lala lalalalalaila lalalalalaila lalalala",
    status: 1,
    tonalidad: "Bm",
    tiempo:0,
  ),
  Song(
    title: "SI TUVIERAS FE",
    text: "Si tuvieras fe como un granito de mostaza, eso dice el Señor, tú le dirías a esa montaña, muévanse, muévanse; esas montañas se moverán, se moverán, se moverán.",
    status: 1,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "VIENE YA",
    text: "Preparemos el camino Cristo viene ya anunciemos su venida en todo lugar que se abran hoy las puertas él viene ya volveremos a adorarle por la eternidad viene ya mi amado pronto le veré viene ya mi amado pronto volverá y voy cantando gritando celebrando su victoria viene ya mi amado Cristo viene ya volveremos cantando volveremos saltando volveremos con gozo volveremos gritando y voy cantando gritando celebrando su victoria viene ya mi amado Cristo viene ya",
    status: 2,
    tonalidad: "Am",
    tiempo:0,
  ),
  Song(
    title: "POPURRÍ D",
    text: "Alabaré, Alabaré, Alabaré, Alabaré, Alabaré a mi señor. Cuando los santos marchen ya hacia la patria celestial, Señor yo quiero estar allá cuando los santos marchen ya. A que tú no sabes lo que en la iglesia pasó, lo que pasó, lo que pasó. Fue el Espíritu Santo, fue el Espíritu Santo, fue el Espíritu Santo, sobre la iglesia se derramó. Oh, qué contento estoy. Si Jesús viene en las nubes con mi hermano yo me voy. Que bueno es cantar cuando hay gratitud, estaré cantando alegre por toda la eternidad. Solamente en Cristo, solamente en Él la salvación se encuentra en Él. No hay otro nombre dado a los hombres, solamente en Cristo, solamente en Él. Una mirada de Fé, una mirada al Señor es la que puede salvar al pecador. Y si tu vienes a Cristo Jesús, Él te perdonará, porque una mirada de Fe es aquel que puede salvar. Éste es el Cristo que yo predico y no me canso de predicar, Él sana a los enfermos, reprende a los demonios y calma la tempestad. Si tu supieras quien es el Señor, arrepentido vendrias a él, su santa sangre en la cruz derramó para salvar al más vil pecador. Yo no sé lo que tú has venido, pero yo vine a alabar a Dios. Aleluya, aleluya, hoy vine a alabar a Dios. Pero que felicidad, pero que felicidad, cantemos todos en coro a nuestro padre celestial.",
    status: 1,
    tonalidad: "D",
    tiempo:0,
  ),
  Song(
    title: "POPURRÍ Dm",
    text: "Cuando el pueblo del señor alaba a Dios suceden cosas, suceden cosas maravillosas. Hay sanidad, liberación, se siente la presencia del señor. Jerusalén Jerusalén que bonita eres, calles de oro, mar de cristal. Por esas calles yo voy a caminar, calles de oro, mar de cristal. En el principio el espíritu de Dios se movia sobre las aguas. Pero ahora se está moviendo dentro de mi corazón. Una cosa sé, que habiendo sido ciego ahora veo la luz de mi Señor. La luz divina que me dio Jesús cuando por la fe yo vi al salvador. Y los fariceos decian sin cesar ese hombre es pecador, ese hombre es pecador. Si es pecador yo no lo sé, lo único que sé, que él me sanó. Los que esperan, los que esperan en Jehová, los que esperan, los que esperan en Jehová. Como las águilas, como las águilas, sus alas levantarán. Correrán y no se cansarán, caminarán, no se fatigarán. Nuevas fuerzas tendrán, nuevas fuerzas tendrán, los que esperan, los que esperan en Jehová. Cristo es la Peña de Horeb que esta brotando agua de vida saludable para ti. Ven a beberla que es mas dulce que la miel, refresca el alma refresca todo tu ser.",
    status: 1,
    tonalidad: "Dm",
    tiempo:0,
  ),
Song(
    title: "POPURRÍ HUAYNOS",
    text: "Amémonos hermanos de todo corazón. Una familia somos de nuestro padre Dios. Ama como Dios te ama. Perdona como Dios perdona. Sin mirar hacia atrás sin volver a pecar vamos pues con Jesús al lugar celestial. Cuando estaba yo lejos del señor cayó una buena semilla en mi corazón. Esa semilla fue la palabra de Dios. Quien cambio mi vida para la gloria de Dios. En las nubes el vendrá en aquel dia final. Cuando Cristo volverá por aquellos que el amó. El sol se oscurecerá al ver la gente llorará. Mas los hijos del señor llenos de gozo estarán. No importa hermanos sufrir aqui no importa hermnos llorar aqui allá en el cielo ya no sufrirás allá en el cielo ya no llorarás. Todo lo hermoso recibirás. Todo lo hermoso recibirás. No importa hermanos sufrir aqui no importa hermnos llorar aqui.",
    status: 1,
    tonalidad: "Dm",
    tiempo:0,
  ),
  Song(
    title: "POPURRÍ MI JESÚS",
    text: "Mi Jesús yo te amo, mi Jesús yo te adoro. Como las águilas volaré, como corderito saltaré. Cantando adorando te alabaré, y dando vueltas me gozaré, saltando danzando te alabaré, y dando vueltas me gozaré. Si me dicen a donde vas, yo voy alabar al Señor, yo voy alabar al Señor. Como lo vas hacer, como lo vas hacer. Voy a Cantar voy a Danzar en Espíritu y en Verdad. Aleluya Aleluya, aleluya Aleluya, aleluya gloria sea a Dios. Yo te alabo yo te adoro, con el corazón te canto y por siempre, te alabare. Por que yo te quiero yo te amo a ti, mi Papito Dios. Por que yo te quiero, yo te amo a ti, papito Jehová. Que más puedo ofrecerte, solamente mi corazón. Solamente mi corazón puedo ofrecerte oh Señor, solamente mi corazón puedo ofrecerte oh Señor. Mi vida, mi vida sólo es tuyo oh SEÑOR, mi vida, mi vida sólo es tuyo oh SEÑOR. Con alegría yo cantaré, alabanzas a mi Señor. Como el cordero yo saltaré, en su presencia me gozaré. Tu fuego está en mi corazón renovando todo mi ser. Arriba las manos dando palmas al Señor. Cantando, Danzando te alabaré Señor Jesús. Cantando, Danzando te alabaré Señor Jesús.",
    status: 1,
    tonalidad: "G",
    tiempo:0,
  ),
];