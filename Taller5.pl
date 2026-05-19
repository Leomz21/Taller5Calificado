personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).

mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragon', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).

puede_aceptar(Personaje, ID_Mision) :-
    personaje(Personaje, Nivel, _),
    mision(Mision, _, Dificultad, _),
    Nivel >= Dificultad.

xp_acumulada(0, 0).
xp_acumulada(N, Total) :-
    N > 0,
    N1 is N - 1,
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).

xp_total_grupo([], 0).

xp_total_grupo([Personaje | Resto], Total) :-
    personaje(Personaje, Nivel, _),
    xp_acumulada(Nivel, XP),
    xp_total_grupo(Resto, XP_Resto),
    Total is XP + XP_Resto.


tiene_requisitos(Personaje, Objeto) :-
    inventario(Personaje, Lista),
    member(Objeto, Lista).


mismo_nivel(P1, P2) :-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.   

es_balanceado(Personaje) :-
    personaje(Personaje, _, Vida),
    Vida =:= 100.   

fusionar_equipo(P1, P2, EquipoFusionado) :-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

tiempo(presente). tiempo(pasado). tiempo(futuro).

persona(primera). persona(segunda).
persona(tercera).

numero(singular). numero(plural).

ser(presente, tercera, singular, "es").
ser(pasado, tercera, singular, "fue").
ser(futuro, tercera, singular, "sera").
ser(presente, primera, singular, "soy").
ser(presente, primera, plural, "somos").
ser(presente, tercera, plural, "son").

conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion) :-
    tiempo(Tiempo), persona(Persona),
    numero(Numero),
    ( Verbo = "ser" ->
        ser(Tiempo, Persona, Numero, R),
        Conjugacion = R
    ; Conjugacion = Verbo ).

generar_reporte(Personaje, MisionID, Mensaje) :-
    puede_aceptar(Personaje, MisionID),
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    atomic_list_concat([Personaje, FormaVerbal,
        "capaz de completar", Nombre, "por", XP, "XP"],
        ' ', Mensaje).


alguien_tiene([Personaje | _], Objeto) :-
    tiene_requisitos(Personaje, Objeto).

alguien_tiene([_ | Resto], Objeto) :-
    alguien_tiene(Resto, Objeto).

cumple_requisitos_grupo(Grupo, MisionID) :-
    requiere(MisionID, Objeto),
    alguien_tiene(Grupo, Objeto),
    fail.

cumple_requisitos_grupo(_, _).

puede_aceptar_grupo(Grupo, MisionID) :-
    mision(MisionID, _, _, XP_Requerida),
    xp_total_grupo(Grupo, XP_Total),
    XP_Total >= XP_Requerida,
    cumple_requisitos_grupo(Grupo, MisionID).

generar_reporte_grupo(Grupo, MisionID, Mensaje) :-
    puede_aceptar_grupo(Grupo, MisionID),
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, plural, FormaVerbal),
    atomic_list_concat(Grupo, ', ', GrupoTexto),
    atomic_list_concat([GrupoTexto, FormaVerbal,
        "capaces de completar", Nombre, "por", XP, "XP"],
        ' ', Mensaje).

%COdigo nuevo del Taller
personaje('Luna', 4, 90).
personaje('Darius', 6, 110).
personaje('Milo', 2, 70).

inventario('Luna', [daga, pocion, amuleto]).
inventario('Darius', [hacha, escudo, pocion]).
inventario('Milo', [lanza, pocion, mapa]).

arma(espada, 40).
arma(arco, 35).
arma(varita, 50).
arma(daga, 25).
arma(hacha, 60).
arma(lanza, 45).

enemigo(bruja, baja, 60).
enemigo(zombi, media, 100).
enemigo(vampiro, alta, 150).
enemigo(demonio, maxima, 220).

arma_personaje(Personaje, Arma) :-
    inventario(Personaje, Lista),
    member(Arma, Lista),
    arma(Arma, _).

danio_jugador(Personaje, Danio) :-
    arma_personaje(Personaje, Arma),
    arma(Arma, Danio).

vida_restante(VidaOriginal, Danio, 0) :-
    Danio >= VidaOriginal.

vida_restante(VidaOriginal, Danio, VidaFinal) :-
    Danio < VidaOriginal,
    VidaFinal is VidaOriginal - Danio.

total_danio_grupo([], 0).

total_danio_grupo([Personaje | Resto], Total) :-
    danio_jugador(Personaje, Danio),
    total_danio_grupo(Resto, TotalResto),
    Total is Danio + TotalResto.

armas_grupo([], []).

armas_grupo([Personaje | Resto], [Arma | RestoArmas]) :-
    arma_personaje(Personaje, Arma),
    armas_grupo(Resto, RestoArmas).

atacar(Personaje, Enemigo) :-
    enemigo(Enemigo, _, VidaOriginal),
    arma_personaje(Personaje, Arma),
    arma(Arma, Danio),
    vida_restante(VidaOriginal, Danio, VidaFinal),
    atomic_list_concat([Danio, 'sobre', VidaOriginal], ' ', DanioTexto),
    (
        Danio >= VidaOriginal ->
        atomic_list_concat(['El jugador', Personaje, 'ataco al enemigo', Enemigo, 'usando', Arma, 'e infligio', DanioTexto, 'de vida original. El enemigo murio y quedo con', VidaFinal, 'de vida'], ' ', Mensaje)
    ;
        atomic_list_concat(['El jugador', Personaje, 'ataco al enemigo', Enemigo, 'usando', Arma, 'e infligio', DanioTexto, 'de vida original. El enemigo sobrevivio y quedo con', VidaFinal, 'de vida'], ' ', Mensaje)
    ),
    writeln(Mensaje).

atacar_grupo(Grupo, Enemigo) :-
    enemigo(Enemigo, _, VidaOriginal),
    total_danio_grupo(Grupo, DanioTotal),
    armas_grupo(Grupo, Armas),
    vida_restante(VidaOriginal, DanioTotal, VidaFinal),
    atomic_list_concat(Grupo, ', ', GrupoTexto),
    atomic_list_concat(Armas, ', ', ArmasTexto),
    atomic_list_concat([DanioTotal, 'sobre', VidaOriginal], ' ', DanioTexto),
    (
        DanioTotal >= VidaOriginal ->
        atomic_list_concat(['Los jugadores', GrupoTexto, 'atacaron al enemigo', Enemigo, 'usando', ArmasTexto, 'e infligio', DanioTexto, 'de vida original como dano total. El enemigo murio y quedo con', VidaFinal, 'de vida'], ' ', Mensaje)
    ;
        atomic_list_concat(['Los jugadores', GrupoTexto, 'atacaron al enemigo', Enemigo, 'usando', ArmasTexto, 'e infligio', DanioTexto, 'de vida original como dano total. El enemigo sobrevivio y quedo con', VidaFinal, 'de vida'], ' ', Mensaje)
    ),
    writeln(Mensaje).