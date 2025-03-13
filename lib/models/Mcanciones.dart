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
  });
}

/*  instrument: 1,
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
    */ 
final List<Song> cancionesCompletas = [
  Song(
    title: "ALELUYA",
    text: """
CANCIÓN: Aleluya - MCLV
TONALIDAD: Em
TIEMPO: 65bpm

INTRO: //Em D//
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
CANCIÓN: Amamos tu presencia - MSM ft. Marcos Brunet
TONALIDAD: E
TIEMPO: 70bpm

INTRO: B - C#m - E - A  x 4

VERSO:
      E                      
//Encuentro  sanidad,  
    C#m
encuentro  libertad
          B       A
En tu presencia    //


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
        
*guitarra electrica*: 
//Bm-G-D-A//
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
      G                  A         F#m Bm
tan cierto como en la mañana se levanta 
      G                A                 D
tan cierto como yo te hablo y me puedes oír.

*Se repite las notas solo cambia la palabra 
"Dios" por "Espíritu* y "Cristo"


CANCIÓN: El Espíritu de Dios - Himno
TONALIDAD: D
TIEMPO: 65bpm

        D                A            D
\\El Espíritu de Dios está en este lugar
      D                 G               A
El Espíritu de Dios se mueve en este lugar
        D            G
Esta aquí para consolar
        D           G
Esta aquí para liberar
        D
Esta aquí para guiar
      A                    D     (D7)
El Espíritu de Dios esta aquí//
              G A             D
\\ Muévete en mi, muévete en mi
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

INTRO: Dm...... Bb - C - Dm

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
        Bb      c    Dm
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

INTRO: //G  D  C  D//

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
      C                     Am          D
escuchándote hablar sin llorar como un niño
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

INTRO: //G  Em  C  D// Am
G                Am
//Algo cayendo aquí
D                      G
  Es tan fuerte sobre mí
Em                 Am
  Mis manos levantaré
D                  G     C-G
  Y su Gloria tocaré//

CORO
D         G                     D
  Está cayendo, su Gloria sobre mi
           Am                    G-C
 Sanando heridas, levantando al caído
                   D
 Su Gloria está aquí//
                   G-Em-C-D
 Su Gloria está aquí *solo una vez*

FINAL
                    //Em-D-Am-D// G
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

INTRO: //Bm G D A// G

    D                  A       Bm
//Así como el ciervo anhela el agua
G                     D        A
Como tierra seca necesita la lluvia
    G    A        D      G
Mi corazón tiene sed de ti
     D        A
mi Dios y mi rey//

CORO:
        Bm-G     D     A
Haz llover    señor Jesús
         Bm       G       A
Derrama lluvia en este lugar
           Bm-G       D     A
Ven con tu rio,    señor Jesús
     Bm    G      A
Inundando mi corazón

*en la guitarra: Bm-G-D-A*

      C#m-A       E     B
Haz llover     señor Jesús
        C#m       A       B
Derrama lluvia en este lugar
           C#m-A     E     B
Ven con tu rio,   señor Jesús
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

INTRO: // G/B - C/G - Bb//
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

Coro
Dm             Bb
Eres Salvador, Hijo de Dios,
 F                       C
Sanas mis heridas, me liberas con Tu Amor,
Dm              Bb
Eres Salvador, Hijo de Dios,
 F                       C
Sanas mis heridas, me liberas del temor
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

INTRO: //D F#m G A//
                  D         F#m7
//Queremos darte gloria, y alabanza
      G                       Em7      
levantamos nuestras manos, adorandote
A
señor//

CORO:
            D
grande eres tú
      A/C#m         Bm7
grande tus milagros son
        F#m       G   G-Em7
no hay otro como tú
       Em         A             
no hay otro como tú

FINAL:
       G    A     D
no hay otro como tú

CANCIÓN: Mereces la gloria - Himno
TONALIDAD: D
TEMPO: 55 bpm

INTRO: //D F#m G A//
                D           F#m  
De Dios es la gloria, y la honra
      G             
levantámos nuestras manos,
     Em        A
exaltándote señor//

CORO 
         D      A/C#m        Bm
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

INTRO: //F#m - E//

VERSO 1:
         F#m
Me has tomado en tus brazos
          E
Y me has dado salvación
       F#m                          E
De tu amor has derramado en mi corazón
      F#m
No sabré agradecerte
            E
Lo que has hecho por mí
      F#m                      E...
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
        F#m7                     E...
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

INTRO:  //Am - G - F//
            Am
Tú eres el Dios de esta tierra
         G 
eres el rey de este pueblo
        F                Dm
esús señor de naciones tu eres
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
  G                             C-G-F
grandes cosas va acontecer este lugar ///
  F
grandes cosas va ocurrir 
  G                          //Am-G-F//
grandes cosas va acontecer aquí
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
"VIDA" por "TIEMPO" Y "AMOR" *
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

VERSO 1:
        Am                G
Haz llover, sobre este lugar,
                  Dm
sediento estoy de Ti.
Dm - Em - F                          Am
Ven  y   sacia hoy la sed que hay en mí,
            G
Lléname de Ti,
             Dm          F               Am  F  
Ven que necesito que refresques mi interior.

VERSO 2:
Am                     G
Ven que quiero más de Ti,
                   Dm
Haz me rebozar mi copa hasta sentir,
Dm - Em - F                          Am
Tu   presencia estremeciendo mi interior,
          G
Ven y tócame,
       Dm           F           Am  G
y abrázame, envuelveme en ti Señor.

CORO:
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
             G        A7      D   G7-D
no vuelvo atrás, no vuelvo atrás

VERSO 2
          D                  Bm
Si otros vuelven  yo sigo a Cristo
          G                   A
si otros vuelven  yo sigo a Cristo
             G        A7      D   G7-D
no vuelvo atrás, no vuelvo atrás

VERSO 3
           D                 Bm
la cruz delante y el mundo atrás
          G                   A
la cruz delante y el mundo atrás
             G        A7      D   G7-D
no vuelvo atrás, no vuelvo atrás
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
            G-D/F#m-Em
Hasta el anochecer
         C     D             G 
Yo cantaré de la bondad de Dios

CORO
C                       G    D 
  En mi vida has sido bueno
C                      G        D 
  En mi vida has sido tan, tan fiel
C                        G-D/F#m-Em
  Con mi ser, con cada aliento
         C    D              G 
Yo cantaré de la bondad de Dios

VERSO 2
        G 
Amo Tu voz
         C             G      
Me has guiado por el fuego
   D/F#m    Em     c         D
Tú cerca estas en la oscuridad
                Em    C 
Te conozco como Padre
         G-D/F#m-Em
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
               Am                       F
La niña de tus ojos por que me amaste a mí//

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

INTRO: // Am - F - C//
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
CANCIÓN: Me diste todo
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

INTRO:// A - B - E/G#m - C#m - B//
A                 B   E/G#m
  Me cautiva tu amor
             C#m        B         A
Solo quiero quedarme aquí a tus pies
                 B    E/G#m
Mi refugio eres tú
                C#m    B
Mi escondite es tú Presencia
 A                  B
Solo quiero ver Tu rostro
        E/G#m           C#m     B
Y contemplarte y contemplarte
A                    B
Tienes toda mi atención
          E/G#m
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

PUENTE: (5X)
A -  C#m  -  B
Jeeeeeeeeeeesús
E/G#m - C#m - B
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

INTRO:// G - A - F#m - Bm - G - A - D//

G     A         F#m    Bm      
  No basta solo con cantar,  
G           A        F#m  Bm    
  no basta solo con decir
G             A     F#m         Bm              
  No es suficiente solo con querer hacer    
A-G         A       D
    es necesario morir.
G     A              F#m   Bm     
  No basta solo con soñar,       
  G           A        F#m  Bm    
  no basta solo con pedir
G             A     F#m         Bm             
  No es suficiente solo con querer hacer    
A-G         A       D
    es necesario morir.

CORO
G          A   F#m           Bm
  Dame tu vida, esa clase de vida que sabes dar
G          A   F#m           Bm
  Dame tu vida,  yo quiero vivir solo para ti
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

INTRO: // A - D//
        A              E/G#m
a tus pies arde mi corazón
       F#m                 D
a tus pies entrego lo que soy
       A              E/G#m
Ese lugar de mi seguridad
      F#m                 D
Donde nadie me puede señalar

PRE-CORO
         D                           E
Me perdonaste, me acercaste a tu presencia
        F#m7                      E/G#m
Me levantaste, hoy me postro a adorarte

CORO
        (A/C#m)     D         E
//No hay lugar más alto, más grande
                F#m7                  A/C#m
Que estar a tus pies, que estar a tus pies //

PUENTE
     D           E       A   E     F#m7
Y aquí permaneceré, postrado a tus pies
     D           E                F#m7     A
Y aquí permaneceré a los pies de Cristo  Oouoh...
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

(VERSO 1)
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

CORO:
D                  A
  Hay poder en la sangre
F#m               E
  Que fluyó por amor
D                   A
  Hay poder en la sangre
             E
Que Él derramó.

(VERSO 2)
Bm          A             F#m C#m
  Preciosa sangre me purificó
Bm          A                   F#m C#m
  Preciosa sangre que me transformó
Bm               A
  Sobre ti el dolor
F#m              D
  Tus venas lloraron
   A     F#m    C#m    E
Jesús, Jesús, Jesús.
(CORO)

INSTRUMENTAL: //Bm-A-F#m-C#m//

PUENTE:
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
TONALIDAD: F#.....G
TIEMPO: 109bpm

INTRO: F# - B - C# 
F#               C#                    B
   Que sería  de mí si no me hubieras alcanzado
F#               C#                     B
   Donde estaría hoy si no me hubieras perdonado
    F#                  C#
Tendría un vacío en mi corazón.
    D#m                  B
Vagaría sin rumbo y sin dirección.

         F#           C#               B
//Si no fuera por tu gracia y por tu amor//
 
  G#m                  D#m                      C#
Sería como un pájaro herido que se muere en el suelo.
  G#m                     D#m                    C#
Sería como un ciervo que brama por agua en el desierto.

          B           C#               F#
//Si no fuera por tu gracia y por tu amor//


*Sube medio tono*
G               D                    C
 ¿Qué sería de mí si no me hubieras alcanzado,
G                D                     C
 ¿Dónde estaría hoy si no me hubieras perdonado,
     G                  D
Tendría un vacío en mi corazón,
     Em                 C
Vagaría sin rumbo, sin dirección.

         G             D               C
//Si no fuera por tu gracia y por tu amor//


    Am                    Em7                   D
//Sería como un pájaro herido que se mueren el suelo
  Am                      Em7                     D
Sería como un ciervo que brama por agua en el desierto.

Bm7       C             D               Em7
   Si no fuera por tu gracia y por tu amor,
        C            D               G
Si no fuera por tu gracia y por tu amor//
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
      "",
      "",
      "https://youtu.be/5qYLQSuJgKI",
      "https://youtu.be/KGQ-91hiW8Y?si=6XixYgmIYdfUsYHs",
    ],
    pianoLink: [
      "",
      "",
      "https://youtu.be/6qQENRi8qUY",
    ],
    bassLink: [
      "https://youtu.be/4F6yGbBlZnw",
      "https://youtu.be/4F6yGbBlZnw",
      "https://youtu.be/jnXp5ZDxPZ8",
    ],
    drumsLink: [
      "",
      "",
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
CANCIÓN: Restauraré hoy el fundamento -
Carlos Mendoza
TONALIDAD: Dm
TIEMPO:  73bpm

INTRO: // Dm - C - Bb//
VERSO
          Dm  C           Bb
 //Levantaré hoy el fundamento
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
    title: "TEMPRANO YO TE BUSCARÉ",
    text: """
CANCIÓN: Temprano yo te buscaré - 
Marcos Witt
TONALIDAD: G
TIEMPO: 119bpm

INTRO: //// G - C ////

G                      D
  Temprano yo te buscaré
C                      Am        D
  De madrugada yo me acercaré a Ti
G                            D   
  Mi alma te anhela y tiene sed
C                 Am7-Am     D
  Para ver Tu gloria y Tu poder

CORO
G      D              Em  C-D
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
    multitrackLink: "",  
    youtubeLink: "https://youtu.be/ADt2wYV6cwM",
    instrument: 1,
    voicesLinks: [
      "https://youtu.be/DO6lyN03L34?si=D6QBdoztnmpZszwV",
    ],
    guitarLink: [
      "",
      "",
      "https://youtu.be/2b3HUzI2mjs",
      "https://youtu.be/XDShbw_Pv6o",
      "https://youtu.be/lcLpOPeBDjI",
      "https://youtu.be/PsVt2JnYPd8",
    ],
    pianoLink: [
      "",
      "",
      "https://youtu.be/VmZAYpnodOQ",
      "https://youtu.be/8Y6pzNLBNHw",
    ],
    bassLink: [
      "https://youtu.be/9ngKvkFBQAA",
      "https://youtu.be/VSWZhUOtuH0",
    ],
    drumsLink: [
      "",
      "",
      "https://youtu.be/afsgHD0x1Jo",
      "https://youtu.be/5AYcTJ68yXM",
    ] 
  ),
  Song(
    title: "TU NOMBRE ES SANTO",
    text: """
CANCIÓN: Tu nombre es santo - Paul Wilbour
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
   Em                C      D         Em
//pues tu nombre es santo, santo, oh Dios//
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
  /*Song(
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
      
    status: 1,
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

