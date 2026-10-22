/* LIBRIS - Ampliación lista para ejecutar, con datos reales integrados.
   Carga 500 libros + 50 socios ficticios + 1500 préstamos terminados.
   Ejecutar como dbo y sin otras cargas simultáneas. Hacer backup antes.
   No crea usuarios SQL: los socios se usan como datos de benchmark. */
USE Libris;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF USER_NAME() <> N'dbo' THROW 50100, N'Ejecuta como dbo, fuera de EXECUTE AS.', 1;
IF @@TRANCOUNT <> 0 THROW 50101, N'No debe haber otra transacción abierta.', 1;
DROP TABLE IF EXISTS #Input, #Genres, #Selected, #Candidates;
DECLARE @data NVARCHAR(MAX) = N'[
  {
    "title": "JURAMENTADA (SAGA EL ARCHIVO DE LAS TORMENTAS 3)",
    "isbn": "9788417347000",
    "synopsis": "Juramentada es la aclamada continuación deEl camino de los reyes y dePalabras radiantes, y tercera parte de la decalogía «El Archivo de las Tormentas», obra maestra de la fantasía épica que ha coronado la lista debest sellers deThe New York Times y ha postulado a Sanderson como el autor de género que más lectores está ganando en todo el mundo.La humanidad se enfrenta a una nueva Desolación con el regreso de los Portadores del Vacío, un enemigo tan grande en número como en sed de venganza. La victoria fugaz de los ejércitos alezi de Dalinar Kholin ha tenido consecuencias: el enemigo parshendi ha convocado la violenta tormenta eterna, que arrasa el mundo y hace que los hasta ahora pacíficos parshmenios descubran con horror que llevan un milenio esclavizados por los humanos.",
    "year": 2018,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2
  },
  {
    "title": "LA VIDA INVISIBLE DE ADDIE LARUE",
    "isbn": "9788416517374",
    "synopsis": "Por la autora de diversos best sellers, V.E. Schwab.Una de las novelas más esperadas de 2020.Un libro autoconclusivo perfecto para los lectores de The Time''s Traveler Wife.Una vida que nadie recuerda.Una historia que nunca olvidarás.Tras hacer un pacto con el diablo, Addie entrega su alma a cambio de la inmortalidad. Sin embargo, ningún trato faustiano está exento de consecuencias: el diablo le entregará la inmortalidad que tanto desea, pero le quitará algo que ella anhelará durante toda su existencia: la posibilidad de ser recordada.Addie abandona su pequeño pueblo natal en la Francia del siglo xviii y comienza un viaje que la lleva por todo el mundo, mientras aprende a vivir una vida en la que nadie la recuerda y todo lo que posee acaba perdido o roto.",
    "year": 2020,
    "authors": [
      "V.e. Schwab"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3
  },
  {
    "title": "EL OJO DEL MUNDO (LA RUEDA DEL TIEMPO Nº 1)",
    "isbn": "9788445007006",
    "synopsis": "Reeditamos la clásica serie de fantasía La Rueda del Tiempo.Este primer volumen incluye los relatos Desde dos ríos y La llaga.La vida de Rand Al’Thor y sus amigos en Campo de Emond ha resultado bastante monótona hasta que una joven misteriosa llega al pueblo. Moraine, una maga capaz de encauzar el Poder Único, anuncia el despertar de una terrible amenaza. Esa misma noche, el pueblo se ve atacado por espantosos trollocs sedientos de sangre, unas bestias semihumanas que hasta entonces se habían considerado una leyenda. Mientras Campo de Emond soporta la ofensiva, Moraine y su guardián ayudan a Rand y a sus amigos a escapar.",
    "year": 2019,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4
  },
  {
    "title": "CRONICAS DE LA DRAGONLANCE Nº 01/03 EL RETORNO DE LOS DRAGONES",
    "isbn": "9788445011041",
    "synopsis": "Son amigos de toda la vida que siguieron caminos distintos. Ahora vuelven a reunirse, aunque cada uno oculta a los demás algún secreto en particular. Hablan de un mundo sobre el que se cierne la sombra de la guerra, cuantan historias de extraños monstruos, de criaturas míticas forjadas en la leyenda, pero no dicen nada de sus secretos. Al menos, no por el momento. No los revelarán hasta que se encuentren con una hermosa y enigmática mujer, que porta una vara mágica. Ella hará que el grupo de amigos se vea inmerso en las sombras, y que sus vidas cambien para siempre, al tiempo que forjan el destino del mundo. Nadie esperaba que fueran unos héroes. Y ellos, menos que nadie.",
    "year": 2022,
    "authors": [
      "Margaret Weis"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 12
  },
  {
    "title": "CRONICAS DE LA DRAGONLANCE Nº 02/03 LA TUMBA DE HUMA",
    "isbn": "9788445011102",
    "synopsis": "Ahora todo el mundo sabe que los esbirros draconianos de Takhisis, la Reina de la Oscuridad, han vuelto. Todas las naciones se disponen a defender sus hogares, sus vidas y su libertad. Pero las razas llevan largo tiempo divididas por el odio y los prejuicios. Los guerreros elfos luchan contra los caballeros humanos. La guerra parece perdida antes de comenzar. Los compañeros se ven separados por el con?icto, viviendo distintas aventuras. Pasará una estación completa antes de que vuelvan a reunirse, si es que lo consiguen. Bajo el pálido sol invernal, un caballero caído en desgracia, una doncella elfa mimada y un kender algo chi?ado ven cómo se acercan las tinieblas. Nadie diría que son unos héroes. Y ellos, menos que nadie.",
    "year": 2022,
    "authors": [
      "Margaret Weis"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 13
  },
  {
    "title": "EL HEROE DE LAS ERAS (SAGA NACIDOS DE LA BRUMA 3)",
    "isbn": "9788466658911",
    "synopsis": "El Héroe de las Eras es el tercer volumen de la saga «Nacidos de la Bruma (Mistborn)». Una obra iniciada conEl imperio final y parte imprescindible del Cosmere, el universo destinado a dar forma a la serie más extensa y fascinante jamás escrita en el ámbito de la fantasía épica.Durante mil años nada ha cambiado: han caído las cenizas, los skaa han sido esclavizados y el Lord Legislador ha dominado el mundo. Kelsier, el «superviviente», el único que ha logrado huir de los Pozos de Hathsin, junto a Vin, una pobre chica skaa, se une a la rebelión. Y por fin lo imposible sucede: por fin la revolución ha triunfado. Pero acabar con el Lord Legislador es la parte sencilla. El verdadero desafío consistirá en sobrevivir a las consecuencias de su caída...",
    "year": 2016,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 14
  },
  {
    "title": "EL RITMO DE LA GUERRA (EL ARCHIVO DE LAS TORMENTAS 4)",
    "isbn": "9788417347932",
    "synopsis": "El Ritmo de la Guerraes la esperada cuarta parte de la decalogía «El Archivo de las Tormentas» y el libro que continúa la historia deEl camino de los reyes, Palabras radiantesyJuramentada.Hay secretos que hemos guardado mucho tiempo. Vigilantes. Insomnes. Eternos. Y pronto dejarán de ser nuestros.La Una que es Tres busca, sin saberlo, el alma capturada. El spren aprisionado, olvidado hace mucho tiempo. ¿Puede liberar su propia alma a tiempo de hallar el conocimiento que condena a todos los pueblos de Roshar?El Soldado Caído acaricia y ama la lanza, incluso mientras el arma hiende su propia carne. Camina siempre hacia delante, siempre hacia la oscuridad, sin luz. No puede llevar consigo a nadie, salvo aquello que él mismo puede avivar.La Hermana Derrumbada comprende sus errores y piensa que ella misma es un error. Parece muy alejada de sus antepasados, pero no comprende que son quienes la llevan a hombros.",
    "year": 2020,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 20
  },
  {
    "title": "TIEMPO DE ODIO (SAGA GERALT DE RIVIA 4) (EDICION COLECCIONISTA)",
    "isbn": "9788498890532",
    "synopsis": "\"Decir que la conocí sería una exageración. Pienso que, excepto el brujo y la hechicera, nadie la conoció de verdad jamás. Cuando la vi por vez primera no me causó especial impresión, incluso pese a las extraordinarias circunstancias que lo acompañaron. Sé de algunos que han afirmado que al instante, a primera vista, percibieron el hálito de la muerte que seguía a esta muchacha. A mí sin embargo me pareció completamente normal, y ya por entonces sabía yo que no era normal, por eso me esforcé en mirar, descubrir, percibir lo extraordinario en ella. Pero nada vi y nada percibí. Nada que pudiera haber sido señal, presentimiento ni profecía de los trágicos acontecimientos posteriores. Aquéllos de los que fue causa.",
    "year": 2010,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 22
  },
  {
    "title": "CRONICAS DE LA DRAGONLANCE Nº 03/03 LA REINA DE LA OSCURIDAD",
    "isbn": "9788445011164",
    "synopsis": "La guerra contra los dragones siervos de la Reina de la Oscuridad sigue su curso. Armados con los misteriosos y mágicos Orbes de los Dragones y con la resplandeciente Dragonlance, los compañeros se convierten en la esperanza del mundo. Por ahora, cuando amanece un nuevo día, los oscuros secretos que han ensombrecido los corazones de este grupo de amigos salen a la luz. La traición, el engaño y la debilidad estarán a punto de destruir todo lo que ya han conseguido. Les queda por librar la más grande de las batallas: cada uno contra sí mismo. Y al final, serán héroes.",
    "year": 2022,
    "authors": [
      "Margaret Weis"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 23
  },
  {
    "title": "EL SILMARILLION (TAPA DURA LUJO)",
    "isbn": "9788445073810",
    "synopsis": "El Silmarilliones el cuerpo central de los textos narrativos de J.R.R. Tolkien, una obra que no pudo publicar en vida porque creció junto con él.Tolkien comenzó a escribirEl Silmarillion mucho antes queEl Hobbit, obra concebida como historia independiente, pero que fue parte de lo que él llamaba un «tema que copia y se ramifica», y del que emergióEl Señor de los Anillos.El Silmarillion cuenta la historia de la Primera Edad, el antiguo drama del que hablan los personajes deEl Señor de los Anillos, y en cuyos acontecimientos algunos de ellos tomaron parte, como Elrond y Galadriel.Los tres Silmarils eran gemas creadas por Fëanor, el más dotado de los Elfos, y contenían la Luz de los Dos Árboles de Valinor antes de que los Árboles mismos fueran destruidos por Morgoth, el primer Señor Oscuro.",
    "year": 2002,
    "authors": [
      "J.r.r. Tolkien"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 24
  },
  {
    "title": "LA CAIDA DE GONDOLIN",
    "isbn": "9788445006092",
    "synopsis": "Conclusión de los Relatos de la Tierra Media que conforman una de las grandes obras de Tolkien, El SilmarillionEn el Cuento deLa Caída de Gondolinchocan dos de los principales poderes del mundo. Por un lado está Morgoth, el mal más absoluto, que está al mando de un enorme poder militar que controla desde su fortaleza en Angband. En su oposición está Ulmo, el segundo Vala más poderoso. Trabaja secretamente en la Tierra Media para apoyar a los Noldor, el grupo de elfos entre los que se contaban Húrin y Túrin Turambar.En el centro de este conflicto entre deidades se encuentra la ciudad de Gondolin, bella pero escondida más allá de toda posibilidad de ser descubierta. Fue construida y habitada por elfos Noldor que se rebelaron contra el poder divino y huyeron desde Valinor, la tierra de los dioses, a la Tierra Media.",
    "year": 2019,
    "authors": [
      "J.r.r. Tolkien"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 28
  },
  {
    "title": "EL ASCENSO DE LA SOMBRA (LA RUEDA DEL TIEMPO Nº 04)",
    "isbn": "9788445007037",
    "synopsis": "Una de las obras maestras de la FantasíaLos sellos de Shayol Ghul se han debilitado y la presencia del Oscuro se hace cada vez más evidente. En Tar Valon, Min es testigo de hechos portentosos que vaticinan un horrible futuro. Los Capas Blancas buscan en Dos Ríos a un hombre con los ojos dorados y siguen el rastro del Dragón Renacido. Perrin, acompañado de Faile, Loial y algunos Aiel llegan allí después de atravesar los Portales de Piedra.Se encontrarán con los Trollocs, que sirven al Oscuro, y con los Capas Blancas y su peculiar manera de entender la defensa de la Luz. Mientras Elayne y Nynaeve parten hacia Tanchico siguiendo el rastro de las Aes Sedai del Ajah Negro que se llevaron los numerosos ter''angreal, Rand trata de reunir a todos los clanes de los Aiel.",
    "year": 2020,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 29
  },
  {
    "title": "LOS HIJOS DE HURIN",
    "isbn": "9788445006498",
    "synopsis": "Nueva edición de Los Hijos de Húrin, con nueva cubierta siguiendo la estética de colección de las ediciones de Beren y Lúthien y La Caída de Gondolin, publicadas recientemente.Los hijos de Húrines uno de los grandes relatos que fundamentan la historia de la Tierra Media y se sitúa en la Primera Edad, cuando elfos, hombres y enanos llevaban unos pocos siglos sobre la tierra. Junto con las historia de Beren y Lúthien, es la historia más mencionada enEl Señor de los Anillos y enEl Silmarillioncomo referente del heroísmo y la tragedia en la lucha contra el Mal, en la Primera Edad encarnado en la figura de Morgoth. Una historia trágica de amores imposibles, pasiones incomprendidas y guerras sin cuartel entre el Bien y el Mal. Con hombres, elfos, enanos, orcos y dragones.",
    "year": 2019,
    "authors": [
      "J.r.r. Tolkien"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 30
  },
  {
    "title": "EL IMPERIO FINAL (SAGA NACIDOS DE LA BRUMA 1)",
    "isbn": "9788417347291",
    "synopsis": "El imperio final inicia la saga «Nacidos de la Bruma [Mistborn]», obra imprescindible del Cosmere, el universo destinado a dar forma a la serie más extensa y fascinante jamás escrita en el ámbito de la fantasía épica.Del autor best seller delNew York Times.Durante mil años han caído cenizas del cielo. Durante mil años nada ha florecido. Durante mil años los skaa han sido esclavizados y viven en la miseria, sumidos en un miedo inevitable.",
    "year": 2018,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 33
  },
  {
    "title": "ARCANUM ILIMITADO: LA COLECCION DEL COSMERE",
    "isbn": "9788466662321",
    "synopsis": "La esperada antología de relatos y novelas cortas del Cosmere, el universo que Brandon Sanderson convertirá en la saga fantástica más extensa e impresionante jamás escrita.Brandon Sanderson crea mundos, y esos mundos están conectados. Su universo se expande por las sagas El Archivo de las Tormentas y Nacidos de la Bruma (Mistborn), también por obras comoElantris, construyendo una constelación de reinos llamado Cosmere.Ahora este espectacular volumen recopila, por primera vez, nueve relatos y novelas cortas representativos de cada uno de esos mundos, con sus distintos sistemas de magia. La colección del Cosmere abarca los límites conocidos del universo de Sanderson -incluida una novela corta inédita de El Archivo de las Tormentas,Bailarina del Filo-, así como ilustraciones, notas...",
    "year": 2017,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 35
  },
  {
    "title": "LOS SEIS DE ATLAS",
    "isbn": "9788416517817",
    "synopsis": "Cada decada se eligen a los seis magosámás extraordinarios para que compitanápor una plaza en la SociedadáAlejandrina, la sociedad secretaámás importante del mundo.Los seleccionados disfrutaránáde una vida de poder y prestigioáque superará sus sueños más salvajes.áPero ¿a que precio?Cada uno de los seis reclutados tieneásus motivos para aceptar la imprecisaáinvitación de la Sociedad. Aunqueátengan que intimar más de lo queáhubieran imaginado con sus enemigosámás peligrosos o sufrir una traiciónáimperdonable de sus mejores aliados,álucharán con uñas y dientes poráel derecho a unirse a las filasáde los alejandrinos.Aunque con ello se arriesguenácon ello a no sobrevivirSECRETOSTRAICIÓNSEDUCCIÓNPODERBIENVENIDOáA LA SOCIEDADáALEJANDRINA",
    "year": 2022,
    "authors": [
      "Olivie Blake"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 38
  },
  {
    "title": "LA COSTA MAS LEJANA",
    "isbn": "9788445012123",
    "synopsis": "El archipiélago de Terramar sufre una grave crisis: la magia está desapareciendo. Ged el Archimago deberá abandonar su amada Roke para descubrir el origen de la desgracia y restaurar el equilibrio. Junto al joven príncipe Arren, emprenderá un arriesgado viaje que los llevará hasta los confines del mundo, hasta la costa más lejana. La segunda entrega del emblemático ciclo de Terramar, en nuestra colección Bibliotecas de Autor.Esta obra ha inspirado populares sagas de fantasía posteriores como Harry Potter.",
    "year": 2022,
    "authors": [
      "Ursula K. Le Guin"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 39
  },
  {
    "title": "LA ESPADA DEL DESTINO (SAGA GERALT DE RIVIA 2) (EDICION COLECCION ISTA)",
    "isbn": "9788498890433",
    "synopsis": "La vida de un brujo cazador de monstruos no es fácil. Tan pronto puede uno tener que meterse hasta el cuello en un estercolero para eliminar a la bestia carroñera que amenaza la ciudad, intentado no atrapar una infección incurable, como se puede encontrar unido a la cacería de uno de los últimos dragones, en la que la cuestión no es si los cazadores conseguirán matar a la pobre bestia, sino qué pasará cuando tengan que repartirse el botín. Magos, príncipes, estarostas, voievodas, druidas, vexlings, dríadas, juglares y criaturas de todo pelaje pueblan esta tierra, enzarzados en conflictos de supervivencia, codicia y amor, y entre ellos avanza, solitario, el brujo Geralt de Rivia.Andrzej Sapkowski es el gran renovador de la literatura fantástica de nuestros tiempos, un genio del lenguaje y la caracterización cuya prosa ya ha hechizado a millones de lectores en todo el mundo.",
    "year": 2010,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 40
  },
  {
    "title": "ELFO OSCURO Nº 02/03 EL EXILIO",
    "isbn": "9788445011096",
    "synopsis": "Hostiles hasta tal punto que un habitante de la superficie jamás podría llegar a imaginar, los laberintos formados por los túneles de la Antípoda Oscura desafían a todos aquellos que se atreven a entrar. Entre ellos están Drizzt Do`Urden y su pantera mágica, Guenhwyvar. Exiliado de Menzoberranzan, la ciudad Drow, Drizzt tiene que luchar para encontrar un nuevo hogar en los interminables laberintos y, además, también ha de defenderse del implacable acoso de su familia, que no le perdona la blasfemia contra la malvada reina Araña. Pero en sus peripecias cuenta con dos amigos que le serán fieles aunque en ello les vaya la vida: en muy honorable capataz, Belwar Dissengulp, y Clark, el Pek.",
    "year": 2022,
    "authors": [
      "R.a. Salvatore"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 43
  },
  {
    "title": "ELFO OSCURO Nº 03/03 EL REFUGIO",
    "isbn": "9788445011157",
    "synopsis": "Muy lejos de la despiadada antípoda oscura, Drizzt Do''Urden lucha por sobrevivir en la superficie del mundo. En busca de un lugar donde sea aceptado por las razas de los reinos, inicia una peregrinación que, a veces, lo desespera e incluso le hace pensar en el regreso a Menzoberranzan. Pero el joven elfo oscuro, acusado injustamente de asesinato, recibe la inesperada ayuda de Montolio, el vigilante ciego, que se preocupará de enseñarle el idioma, las costumbres y la manera de ser de los habitantes de la superficie.",
    "year": 2022,
    "authors": [
      "R.a. Salvatore"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 45
  },
  {
    "title": "SOMBRAS DE IDENTIDAD (SAGA NACIDOS DE LA BRUMA 5)",
    "isbn": "9788466658850",
    "synopsis": "Sombras de identidad es el quinto libro de la saga «Nacidos de la Bruma [Mistborn]», una obra iniciada con El imperio final y parte imprescindible del Cosmere, el universo destinado a convertirse en la serie más extensa y fascinante jamás escrita en el ámbito de la fantasía épica.La sociedad de Nacidos de la Bruma ha evolucionado en una fusión de magia y tecnología en la que la economía se expande, la democracia se enfrenta a la corrupción y la religión se convierte en una potencia cultural cada vez más influyente, con cuatro fes distintas enfrentadas por la captación de conversos.Esta sociedad tan animada y optimista, aunque todavía tambaleante, se enfrenta ahora a su primera amenaza de terrorismo, crímenes cuyo objetivo es fomentar el descontento de la clase trabajadora y avivar las llamas de los conflictos religiosos.",
    "year": 2016,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 49
  },
  {
    "title": "EL RETORNO DE NAGASH (CICLO WARHAMMER THE END TIMES 1/5)",
    "isbn": "9788445003374",
    "synopsis": "El retorno de Nagash inaugura The End Times, la nueva serie de Warhammer que explica el fin del Viejo Mundo.El fin del Viejo Mundo ha llegado. Mientras las fuerzas del Caos amenazan con anegar el mundo en la locura, Mannfred von Carstein y Arkhan el Negro dejan a un lado sus diferencias y planean resucitar al único ser con el poder de luchar contra los sirvientes de los Poderes Ruinosos y restaurar el orden en el mundo: el Gran Nigromante en persona. Mientras reúnen los artefactos necesarios para su oscuro ritual, los ejércitos convergen en Sylvania con el objetivo de detenerlos. Pero Arkhan y Mannfred están decididos a llevar a cabo su misión. Nagash debe levantarse de nuevo, a cualquier precio.",
    "year": 2016,
    "authors": [
      "Josh Reynolds"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 50
  },
  {
    "title": "ALEACION DE LEY (SAGA NACIDOS DE LA BRUMA 4)",
    "isbn": "9788466658928",
    "synopsis": "Aleación de ley es la secuela de la primera trilogía de la saga «Nacidos de la Bruma [Mistborn]», una obra iniciada conEl imperio final y parte imprescindible del Cosmere, el universo destinado a dar forma a la serie más extensa y fascinante jamás escrita en el ámbito de la fantasía épica.Han pasado trescientos años desde los acontecimientos narrados en la primera trilogía de la saga, y Scadrial se encuentra ahora cerca de la modernidad: ferrocarriles, canales, iluminación eléctrica y los primeros rascacielos invaden el planeta. Aunque la ciencia y la tecnología están alcanzando nuevos retos, la antigua magia de la alomancia continúa desempeñando un papel fundamental. En una zona conocida como los Áridos, existen herramientas cruciales para aquellos hombres y mujeres que intentan establecer el orden y la justicia.",
    "year": 2016,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 51
  },
  {
    "title": "EL POZO DE LA ASCENSION (SAGA NACIDOS DE LA BRUMA 2)",
    "isbn": "9788466658904",
    "synopsis": "El Pozo de la Ascensión es el segundo volumen de la saga «Nacidos de la Bruma [Mistborn]», una obra iniciada conEl imperio final y parte imprescindible del Cosmere, el universo destinado a dar forma a la serie más extensa y fascinante jamás escrita en el ámbito de la fantasía épica.Durante mil años nada ha cambiado: han caído las cenizas, los skaa han sido esclavizados y el Lord Legislador ha dominado el mundo. Pero lo imposible ha sucedido. El Lord Legislador ha muerto. Sin embargo, vencer y matarlo fue la parte sencilla. El verdadero desafío será sobrevivir a las consecuencias de su caída.Tomar el poder tal vez resultó fácil, pero ¿qué ocurre después?, ¿cómo se utiliza? La tarea de reconstruir el mundo, ahora que Kelsier no está, ha quedado en manos de Vin.",
    "year": 2016,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 52
  },
  {
    "title": "HECHICERO",
    "isbn": "9788445012215",
    "synopsis": "Se dice que fue Briamor Candess quien, ayudado por otros cuatro hechiceros, construyó la altiva e impresionante torre ciudadela destinada a albergar a toda la comunidad de hechiceros que hasta entonces existían repartidos por el mundo, y que se llamó La Luz del Oeste. Durante muchísimo tiempo fue un lugar al que el mundo miraba con ojos admirados y asustados, pues era hipocentro de un poder desatado. Mas el poder está siempre en los ojos de aquellos que codician, y La Luz del Oeste no iba a ser una excepción. Hechicero cuenta la parábola de Ellör Litos Ceoril, uno de los Cinco Fundadores, desde los primeros días de gloria hasta que se vio obligado a vivir en el exilio, oculto y apartado, y... lo que pasó después. Hechicero rebosa magia y recoge el testimonio del auge y caída de la Luz del Oeste tal y como ocurrió.Como Nigromante, contará con cubierta e ilustraciones interiores a todo color del prestigioso ilustrador Tomás Hijo.",
    "year": 2022,
    "authors": [
      "Carlos Sisi"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 55
  },
  {
    "title": "UN TRATO CON EL REY DE LOS ELFOS",
    "isbn": "9788416517695",
    "synopsis": "Los elfos vienen por dos motivos: por la guerra y para encontrar esposa. En ambos casos, traen consigo la muerte. Hace tres mil años, los humanos eran cazados por poderosas razas poseedoras de una magia salvaje, hasta que se estableció un pacto. Ahora, y desde hace siglos, los elfos toman a una joven del pueblo de Luella para ser su Reina Humana. Ser «la elegida» es interpretado como una sentencia de muerte por la gente del pueblo. Una marca de la que Luella, de diecinueve años, está agradecida de haber escapado en su infancia. En cambio, ha dedicado su vida a estudiar herbología y convertirse en la única curandera del pueblo. Hasta que el Rey Elfo llega inesperadamente… a buscarla. Todo cuanto Luella pensaba que sabía sobre su vida y sobre sí misma era, en realidad, una mentira. Llevada a una tierra rebosante de magia salvaje, se ve obligada a ser la nueva reina de un Rey Elfo frío pero tremendamente atractivo.",
    "year": 2022,
    "authors": [
      "Elise Kova"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 58
  },
  {
    "title": "LA RUEDA DEL TIEMPO Nº 10/14 ENCRUCIJADA EN EL CREPUSCULO",
    "isbn": "9788445007099",
    "synopsis": "Décima entrega de la mítica saga de Fantasía, La Rueda del Tiempo de Robert Jordan.Mat Cauthon huye con la hija de las Nueve Lunas mientras la Sombra y el imperio seanchan emprenden una persecución implacable. La heredera del Trono de Andor, rodeada de enemigos que planean su destrucción, puede caer en manos de la Sombra y arrastrar consigo al Dragón Renacido, y Egwene al’Vere pone sitio al centro de poder Aes Sedai, pero ha de vencer con rapidez para evitar que los Asha’man sean los únicos capaces de defender el mundo del Oscuro.Tras limpiar la mitad masculina de la Fuente Verdadera, Rand Al’Thor se ve obligado a correr grandes riesgos sin saber con certeza quienes son sus aliados y quienes sus enemigos.",
    "year": 2021,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 61
  },
  {
    "title": "LA RUEDA DEL TIEMPO Nº 09/14 EL CORAZON DEL INVIERNO",
    "isbn": "9788445007082",
    "synopsis": "Tras el ataque en el Palacio del Sol, Rand viaja con Min dejando pistas falsas a sus enemigos. En Cairhien, Cadsuane continúa preparando la estrategia para la Última Batalla. Perrin organiza el rescate de Faile, que está prisionera del septiar de Sevanna, y en Tar Valon se suceden las intrigas de la Torre Blanca. Los seanchan han conquistado Ebou Dar y Mat se encuentra atrapado allí, junto a sus compañeros. Rand se dirige a Far Madding, la ciudad donde el Poder no surte efecto. Allí espera enfrentarse a los Asha''man renegados, condición que considera necesaria para limpiar el Saidin de la infección del Oscuro.",
    "year": 2021,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 64
  },
  {
    "title": "EL SEÑOR DE LOS ANILLOS (NE). ILUSTRADO POR ALAN LEE",
    "isbn": "9788445011119",
    "synopsis": "Los Anillos de Poder fueron forjados en antiguos tiempos por los herreros Elfos, y Sauron, el Señor Oscuro, forjó el Anillo Único. Pero en una ocasión se lo quitaron, y aunque lo buscó por toda la Tierra Media nunca pudo encontrarlo. Al cabo de muchos años fue a caer casualmente en manos del hobbit Bilbo Bolsón.Desde la Torre Oscura de Mordor, el poder de Sauron se extendió alrededor. Llegó a reunir todos los Grandes Anillos, pero continuaba buscando el Anillo Único, que completaría el dominio de Mordor. Bilbo desapareció durante la celebración de su centesimodecimoprimer cumpleaños, y dejó a Frodo a cargo del Anillo, y con una peligrosa misión por delante: atravesar la Tierra Media, internarse en las sombras del País Oscuro y destruir en Anillo arrojándolo en las Grietas del Destino.",
    "year": 2022,
    "authors": [
      "J.r.r. Tolkien"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 68
  },
  {
    "title": "BAUTISMO DE FUEGO (SAGA GERALT DE RIVIA 5) (EDICION COLECCIONISTA )",
    "isbn": "9788498890549",
    "synopsis": "Entonces le dijo la profetisa al brujo: \"Este consejo te doy: ponte botas de yerro, toma en la mano un bastón de yerro. Ve con tus botas de yerro hasta el fin del mundo y por el camino agita el bastón y riega todo con lágrimas. Ve a través de la agua y el fuego, no te detengas ni mires a tu alredor. Y cuando las almadreñas se te desgasten, cuando el bastón de yerro se deshaga, cuando el viento y el calor te sequen los ojos de tal forma que de ellos ni una lágrima acierte a escapar, entonces, en el fin del mundo, hallarás lo que buscas y lo que amas. Pudiera ser\".Y el brujo cruzó la agua y el fuego, sin mirar a su alrededor. Pero no se puso botas de yerro ni tomó bastón. Sólo llevó su espada de brujo. No escuchó las palabras de la profetisa. Y bien que hizo, porque era una mala profetisa.",
    "year": 2010,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 72
  },
  {
    "title": "LA TORRE DE LA GOLONDRINA (SAGA GERALT DE RIVIA 6 (EDICION COLECC IONISTA)",
    "isbn": "9788498890570",
    "synopsis": "\"-Puedo darte todo lo que desees -dijo el hada-. Riqueza, poder y cetro, fama, una vida larga y feliz. Elige.-No quiero riqueza ni fama, poder ni cetros -respondió la bruja-. Quiero un caballo que sea negro y tan imposible de alcanzar como el viento de la noche. Quiero una espada que sea luminosa y afilada como los rayos de la luna. Quiero atravesar el mundo en la oscura noche con mi caballo negro, quiero quebrar las fuerzas del Mal y de la Oscuridad con mi espada de luz. Eso es lo que quiero.-Te daré un caballo que será más negro que la noche y más ligero que el viento de la noche -le prometió el hada-. Te daré una espada que será más luminosa y afilada que los rayos de la luna. Pero no es poco lo que pides, bruja, habrás de pagármelo muy caro.-¿Con qué? En verdad nada tengo.-Con tu sangre.\"Flourens Delannoy, Cuentos y leyendas",
    "year": 2011,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 73
  },
  {
    "title": "LA DAMA DEL LAGO (SAGA GERALT DE RIVIA 7) (EDICION COLECCIONISTA)",
    "isbn": "9788498890624",
    "synopsis": "\"De las llamitas, algunas altas y poderosas eran, vivamente brillaban y con claridad, otras por su parte eran pequeñas, vacilantes y temblorosas, y oscurecíase su luz y amortiguábase a trechos. En el mismo final había una llamita pequeña y tan débil que apenas ardía, apenas se removía, ora brillando con gran esfuerzo, ora casi, casi apagándose del todo. -¿De quién es ese fueguecillo moribundo? -preguntó el brujo.-Tuyo -respondió la Muerte.\" Flourens Delannoy, Cuentos y leyendasAndrzej Sapkowski es el gran renovador de la literatura fantástica de nuestros tiempos, un genio del lenguaje y la caracterización cuya prosa ya ha hechizado a millones de lectores en todo el mundo.",
    "year": 2011,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 74
  },
  {
    "title": "EL TEMOR DE UN HOMBRE SABIO (SAGA CRONICA DEL ASESINO DE REYES 2)",
    "isbn": "9788401339639",
    "synopsis": "Llega El temor de un hombre sabio, la esperada continuación de la historia de Kvothe y El nombre del viento. \"Todo hombre sabio teme tres cosas: la tormenta en el mar, la noche sin luna y la ira de un hombre amable.\" El hombre había desaparecido. El mito no. Músico, mendigo, ladrón, estudiante, mago, trotamundos, heroe y asesino, Kvothe había borrado su rastro. Y ni siquiera ahora que le han encontrado, ni siquiera ahora que las tinieblas invaden los rincones del mundo, está dispuesto a regresar. Pero su historia prosigue, la aventura continúa, y Kvothe seguirá contándola para revelar la verdad tras la leyenda. \"Me llamo Kvothe. Quizá hayas oído hablar de mí.\" La crítica ha dicho.\"La nueva promesa de la literatura fantástica.\"Que leer \"El Tolkien estadounidense.\"Juan Gómez-Jurado, ABC",
    "year": 2011,
    "authors": [
      "Patrick Rothfuss"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 75
  },
  {
    "title": "EL NOMBRE DEL VIENTO (SAGA CRONICA DEL ASESINO DE REYES 1)",
    "isbn": "9788401337208",
    "synopsis": "Atípica, profunda y sincera,El nombre del viento es una novela de aventuras, de historias dentro de otras historias, de misterio, de amistad, de amor, de magia y de superación.La novela que ha consagrado a Patrick Rothfuss como fenómeno editorial de los últimos años.En una posada en tierra de nadie, un hombre se dispone a relatar, por primera vez, la auténtica historia de su vida. Una historia que únicamente él conoce y que ha quedado diluida tras los rumores, las conjeturas y los cuentos de taberna que le han convertido en un personaje legendario a quien todos daban ya por muerto: Kvothe... músico, mendigo, ladrón, estudiante, mago, héroe y asesino.Ahora va a revelar la verdad sobre sí mismo.",
    "year": 2009,
    "authors": [
      "Patrick Rothfuss"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 78
  },
  {
    "title": "ELFO OSCURO Nº 01/03 LA MORADA",
    "isbn": "9788445011072",
    "synopsis": "La extraña y exótica Menzoberranzan, la gran ciudad de la Antípoda Oscura, fundada hace milenios por los elfos oscuros tras su marcha del mundo exterior, es la morada del héroe de \"El valle del viento helado\", Drizzt Do''Urden. Drizzt, el joven príncipe de una de las casas regentes, llega a la madurez en el mundo cruel y despiadado de su raza, donde el único rayo de esperanza es su maestro de armas, Zaknafein, quien le enseña cómo -y para qué- usar una espada. Dotado de un honor incomprensible para la sociedad sin principios que lo rodea, atenta únicamente a satisfacer los viles caprichos de la reina Araña, el joven Drizzt se enfrenta a un dilema inevitable: ¿podrá vivir en un mundo que rechaza la integridad?",
    "year": 2022,
    "authors": [
      "R.a. Salvatore"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 83
  },
  {
    "title": "LA SOMBRA DE DREINLAR",
    "isbn": "9788445011065",
    "synopsis": "Galwyn Galradab regresa a su hogar después de catorce años para asistir a las nupcias entre su primo, el heredero de Thadded, y la hija de uno de los señores más poderosos del reino de Altain. Sin embargo, el incremento en el patrimonio de su familia, la cantidad de mercenarios acumulados, la presencia de unos bandidos y la amenaza de un ladrón legendario le plantearán numerosas dudas y le harán temer por la estabilidad del feudo. Pronto, sus sospechas le llevarán a comprender que en Thadded se está urdiendo una conspiración que escapa a su control y que hará sacudir no solo su reino sino todo Dreinlar.",
    "year": 2022,
    "authors": [
      "Bernard Torello Lopez"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 86
  },
  {
    "title": "EL JUEGO DEL PRINCIPE (SAGA EL PRINCIPE CAUTIVO 2)",
    "isbn": "9788417525033",
    "synopsis": "Sus dos países están al borde de la guerra. Damen y su amo, el príncipe Laurent, se ven obligados a dejar atrás las intrigas de palacio por la brutalidad del combate en el campo de batalla y viajan a la frontera para impedir una conspiración letal. Obligado a ocultar su verdadera identidad, Damen se siente cada vez más atraído hacia el peligroso y carismático Laurent.",
    "year": 2018,
    "authors": [
      "C. S. Pacat"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 88
  },
  {
    "title": "ASSASSIN S CREED VALHALLA",
    "isbn": "9788445009536",
    "synopsis": "¡Novela oficial del videojuego de Ubisoft!Vive tu propia leyenda vikinga acompañando al legendario guerrero vikingo Eivor, líder de su clan en los gélidos páramos nórdicos, en su épica aventura hasta un nuevo hogar en la Inglaterra del siglo IX. Eivor tratará de conquistar una Inglaterra fracturada y dominada por reinos en guerra y señores feudales.",
    "year": 2020,
    "authors": [
      "Matthew J. Kirby"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 93
  },
  {
    "title": "DRAGONLANCE: QUINTA ERA (EDICION COLECCIONISTA)",
    "isbn": "9788448038229",
    "synopsis": "Por primera vez en Edición Coleccionistas la trilogía de Dragonlance en que se resuelve la pugna entre los malignos dragones y una nueva generación de héroesLos dioses se han desvanecido y la magia se ha debilitado hasta casi desaparecer de Krynn. Es la Era de los Mortales, pero también es la Era de los Dragones, que arrasan pueblos, esclavizan a sus gentes y se proclaman señores supremos de Ansalon. Han alterado la tierra por medios mágicos, esculpiendo sus dominios de acuerdo con sus viles inclinaciones, y ahora comienzan a reunir ejércitos de dragones, humanoides y criaturas.Incluso los antaños orgullosos Caballeros de Takhisis se han unido a sus filas y preparan el ataque contra los ciudadanos de Ansalon. Sin embargo, un puñado de humanos no quiere rendirse.",
    "year": 2001,
    "authors": [
      "Jean Rabe"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 94
  },
  {
    "title": "PALABRAS RADIANTES (SAGA EL ARCHIVO DE LAS TORMENTAS 2)",
    "isbn": "9788466657549",
    "synopsis": "La aclamada continuación deEl camino de los reyes es, como el primer volumen de «El Archivo de las Tormentas», el resultado de más de una década de construcción y escritura de universos, convertida en una obra maestra de la fantasía contemporánea en diez volúmenes. Brandon Sanderson se postula con ella como el autor del género que más lectores está ganando en todo el mundo.Los Caballeros Radiantes deben volver a alzarse.Los antiguos juramentos por fin se han pronunciado. Los hombres buscan lo que se perdió. Temo que la búsqueda los destruya.Es la naturaleza de la magia. Un alma rota tiene grietas donde puede colarse algo más. Las potencias, los poderes de la creación misma, pueden abrazar un alma rota, pero también pueden ampliar sus fisuras.El Corredor del Viento está perdido en una tierra quebrada, en equilibro entre la venganza y el honor.",
    "year": 2015,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 95
  },
  {
    "title": "UNA PRINCESA DE MARTE: BAJO LAS LUNAS DE MARTE 1",
    "isbn": "9788492492701",
    "synopsis": "Hace ahora cien años que Edgar Rice Burroughs, un hombre apenas sin futuro en aquellos días, decidió volcarse en una nueva carrera: la de escritor profesional. Su primera obra le llevo´ a la fama. A partir de ese momento, todo para él fue un maravilloso viaje por la vida. Esta primera novela de su Serie Marciana once volúmenes llenos de aventura, intriga y, quizá, ciencia ficción nos lleva a recorrer un planeta Marte donde conviven multitud de razas de muy diversa índole, condición y colores, todas ellas enfrentadas en una serie continua de guerras y enfrentamientos.",
    "year": 2012,
    "authors": [
      "Edgar Rice Burroughs"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 99
  },
  {
    "title": "PROMESA DE SANGRE (MAGOS DE LA POLVORA 1)",
    "isbn": "9788412299229",
    "synopsis": "Derrocar a un rey es un trabajo sangriento. El mariscal de campo Tamas ha liderado el golpe de estado en Adro. La aristocracia decadente y corrupta ha terminado en la guillotina y el pueblo hambriento ahora tiene comida. Pero además ha provocado la guerra en las Nueve Naciones, ataques internos de los realistas y lucha encarnizada por el dinero y el poder entre quienes suponía eran sus aliados: la Iglesia, los trabajadores y los mercenarios. Tamas apenas soporta la presión y necesita a Adamat, un inspector de policía retirado, cuya lealtad está en juego, y a los Magos de la Pólvora que le quedan, entre ellos Taniel, su indómito y brillante hijo. Hay quienes presagian muerte y destrucción. Las leyendas están en boca del pueblo pero ningún hombre instruido cree en ese tipo de cosas... aunque sería mejor que lo hicieran. Los dioses también están implicados.",
    "year": 2021,
    "authors": [
      "Brian Mcclellan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 101
  },
  {
    "title": "ESQUIRLA DEL AMANECER (EL ARCHIVO DE LAS TORMENTAS 3.5)",
    "isbn": "9788418037238",
    "synopsis": "Esquirla del Amanecer es una historia que forma parte de la decalogía El Archivo de las Tormentas y está ambientada entreJuramentada yEl Ritmo de la Guerra. Sigue la estela deDanzante del Filoy permite que brillen unos personajes que suelen quedar eclipsados.Brandon Sanderson es el gran renovador de la fantasía del siglo XXI, con diecinueve millones de lectores en todo el mundo.Tras el descubrimiento de un barco fantasma, cuya tripulación al parecer murió intentando llegar a la isla de Akinah, rodeada por tormentas, Navani Kholin deberá enviar una expedición para asegurarse de que la isla no haya caído en manos enemigas.",
    "year": 2021,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 102
  },
  {
    "title": "EL ULTIMO RITUAL",
    "isbn": "9788445011577",
    "synopsis": "Un libro Arkham Horror.El aspirante a pintor Alden Oakes es invitado a unirse a una misteriosa comuna artística enArkham: la Nueva Colonia. Cuando el aclamado l JuanHugo Balthazarr la visita, Alden y el resto de artistas no tardan en caer bajo su carismático hechizo. Balthazarr organiza una serie de fiestas llenas de excesos para la alta sociedad deArkham y conjura ilusiones arcanas que difuminan los límites entre el sueño y la realidad.Poco a poco,Alden empieza a sospechar que los rituales falsos deBalthazarr están destinados a romper esos muros y liberar lo que se esconde tras ellos. Alden debe actuar, pero puede que ya sea demasiado tarde para salvar a Arkham... o incluso a sí mismo.",
    "year": 2022,
    "authors": [
      "S. A. Sidor"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 103
  },
  {
    "title": "UNA OBSESION PERVERSA",
    "isbn": "9788416517602",
    "synopsis": "NO TE PIERDAS UNA DE LAS SERIES MÁS EXITOSAS DE V.E. SCHWAB, LA AUTORA BEST SELLER DE LA VIDA INVISIBLE DE ADDIE LARUE.Ambiciosos.Arrogantes.Brillantes.ExtraOrdinarios.¿Ya conoces a Victor Vale y a Eli Cardale?En el último año de su carrera, el interés compartido por la adrenalina, las experiencias cercanas a la muerte y los acontecimientos en apariencia sobrenaturales plantean una posibilidad intrigante: que, dadas ciertas condiciones, sería posible desarrollar habilidades ExtraOrdinarias. Pero cuando la tesis pasa de lo académico a lo experimental, las cosas salen horriblemente mal.Diez años más tarde, Victor escapa de la cárcel, decidido a encontrar a su antiguo amigo (ahora enemigo), con la ayuda de una niña cuyo carácter reservado esconde una capacidad asombrosa. Mientras tanto, Eli se ha propuesto erradicar a todas las demás personas con superpoderes que pueda encontrar...",
    "year": 2021,
    "authors": [
      "V.e. Schwab"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 104
  },
  {
    "title": "LA PLUMA MAGICA DE GWENDY (LA CAJA DE BOTONES DE GWENDY 2)",
    "isbn": "9788491296270",
    "synopsis": "En esta secuela de La caja de botones deGwendy, de Stephen King y RichardChizmar, la adultaGwendy Peterson vuelve aCastle Rock tras la desaparición de dos jóvenes... y el regreso de su misteriosa caja de botones.Han pasado 15 años desde que Gwendy Peterson dejó Castle Rock. Ahora tiene 37, vive en Washington D. C. y apenas recuerda a la adolescente que volvía a casa en verano a través de las Escaleras de los Suicidios.Sin embargo, su caja de botones reaparece y Gwendy descubre que en Castle Rock han desaparecido dos chicas. El sheriff Ridgewick y su equipo trabajan a contrarreloj para encontrarlas sin saber a qué clase de enemigo se enfrentan. Pero Gwendy sí lo sabe, y es consciente de que solamente ella podrá traerlas de vuelta., pero solo si utiliza la poderosa pero peligrosa caja de botones una vez más.La crítica ha dicho:«Dos jóvenes son secuestradas y una Gwendy paranoica que no puede dejar de vigilar sus espaldas.",
    "year": 2022,
    "authors": [
      "Richard Chizmar"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 109
  },
  {
    "title": "AMANECER ROJO 1",
    "isbn": "9788491876939",
    "synopsis": "Durante más de una década, un solo hombre aterrorizó a la ciudad de Nueva York colocando más de una treintena de bombas en lugares públicos, generalmente muy concurridos. A pesar de los indicios que dejaba en los escenarios del crimen y de los numerosos mensajes que firmaba como F. P., la policía siempre se mostró incapaz de averiguar su identidad. Como los métodos tradicionales fracasaban uno tras otro, al final se optó por probar algo atípico que la mayoría de los agentes consideraban absurdo: recurrir a un psiquiatra.Incendiario narra la increíble historia de un terrorista que la prensa de la época calificó como «la mayor amenaza individual a la que se haya enfrentado Nueva York». Pero también es el relato de la introducción del perfil criminal como herramienta de incalculable valor en las investigaciones policiales.A FINALES DE 1956, LA POLICÍA NEOYORQUINA IBA A CAMBIAR SU METODOLOGÍA PARA SIEMPRE",
    "year": 2022,
    "authors": [
      "Pierce Brown"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 112
  },
  {
    "title": "EL DRAGON RENACIDO (LA RUEDA DEL TIEMPO Nº 3)",
    "isbn": "9788445007020",
    "synopsis": "Nueva edición de la saga de Fantasía de Robert JordanRand, acosado por inquietantes sueños sobre una espada de cristal, decide abandonar a sus compañeros tras un ataque de Engendros de la Sombra y se encamina hacia Tear para descubrir quién es realmente. Mientras tanto, las tres jóvenes aspirantes a Aes Sedai viajan con Mat hacia Tar Valon para ingresar como novicias en la Torre Blanca, donde esperan que las hermanas sanen a Mat de la extraña enfermedad que padece. Poco tiempo después, la Amyrlin les encomienda una peligrosa misión. . .Por su calidad literaria, su ambicioso planteamiento y su descomunal historia, La Rueda del Tiempo es la saga de fantasía más importante de los últimos treinta años. El lector que inicie el camino junto a Rand, Mat y Perrin no podrá abandonar el viaje hasta su incierto y sorprendente final.",
    "year": 2020,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 121
  },
  {
    "title": "UN MUNDO HELADO",
    "isbn": "9788408213789",
    "synopsis": "La familia de Miryem se halla al borde de la pobreza, hasta que se hace cargo de la situación y no tarda en ganarse la reputación de ser capaz de convertir la plata en oro. Cuando el rey de los staryk, unas criaturas hechas de hielo que amenazan con llevarse el verano para siempre, se entera de tal hazaña le impone una tarea que parece imposible y que hará que Miryem descubra que tiene poderes. Tejerá una telaraña en la que quedarán atrapadas una joven campesina, Wanda, y la desdichada hija de un noble local que pretende casarla con el joven y apuesto zar Mirnatius. Miryem y sus dos inesperadas aliadas se embarcarán en una desesperada odisea que las llevará hasta los límites del sacrificio, el poder y el amor.",
    "year": 2019,
    "authors": [
      "Naomi Novik"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 122
  },
  {
    "title": "CONJURO DE LUZ (TRILOGIA SOMBRAS DE MAGIA 3)",
    "isbn": "9788445006030",
    "synopsis": "La oscuridad ha proyectado sus sombras, ¿aprovechará otro Londres para resurgir? La respuesta en la tercera y última entrega de la trilogía Sombras de Magia.El conflicto está servido en los distintos Londres. Las fuerzas de Kell, quien creyó ser el último Antari vivo, comienzan a flaquear bajo la presión de sus rivales. Frente a la tragedia, ¿podrá sobrevivir Arnes? ¿Quién se alzará? Lila Bard, quien fue una ladrona común, ha sobrevivido y se ha vuelto cada vez más fuerte al atravesar una serie de combates mágicos.Pero ahora deberá aprender a controlar la magia, antes de que esta pueda consumirla. Mientras tanto, el desprestigiado capitán del Aguja Nocturna, Alucard Emery, reúne a su tripulación y juntos emprenden una carrera contra el tiempo para conseguir lo imposible. ¿Quién tomará el control? Además, un viejo enemigo regresa a reclamar la corona, mientras un héroe caído intenta salvar a un mundo de la descomposición.",
    "year": 2019,
    "authors": [
      "V.e. Schwab"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 123
  },
  {
    "title": "Y VENDRA LA OSCURIDAD (TRILOGIA LA ERA DE LA OSCURIDAD 1)",
    "isbn": "9788416517244",
    "synopsis": "«Un debut imperdible de una escritora nueva y con mucho talento. Te desafío a no dejarte llevar por esta fantasía atractiva y compleja.»-Kiersten White, autora de Hija del dragón, best seller del New York Times«La verdadera magia de Y vendrá la oscuridad reside en los héroes que Pool creó: enredados, imperfectos y muy humanos. Ya verás que es imposible no enamorarse de todos ellos.»-Laura Sebastian, autora de Princesa de cenizas, best seller del New York Times«Esta historia, con su ritmo vertiginoso y sus personajes bien retratados, me mantuvo en vilo hasta la última página.»-Julie C. Dao, autora de El bosque de los mil farolillos«Katy Rose Pool combina personajes adorables, un mundo tangible y encantador, y una trama elaborada, con piezas que se acomodan como en un rompecabezas.",
    "year": 2019,
    "authors": [
      "Katy Rose Pool"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 124
  },
  {
    "title": "FUEGO Y SANGRE (CANCION DE HIELO Y FUEGO) (RUSTICA)",
    "isbn": "9788401024061",
    "synopsis": "El nuevo libro de George R. R. Martin narra la fascinante historia de los Targaryen, la dinastía que reinó en Poniente trescientos años antes del inicio de«Canción de hielo y fuego», la saga que inspiró la serie de HBO:Juego de tronos.Siglos antes de que tuvieran lugar los acontecimientos que se relatan en «Canción de hielo y fuego», la casa Targaryen, la única dinastía de señores dragón que sobrevivió a la Maldición de Valyria, se asentó en la isla de Rocadragón.Aquí tenemos el primero de los dos volúmenes en el que el autor deJuego de tronos nos cuenta, con todo lujo de detalles, la historia de tan fascinante familia: empezando por Aegon I Targaryen, creador del icónico Trono de Hierro, y seguido por el resto de las generaciones de Targaryens que lucharon con fiereza por conservar el poder, y el trono, hasta la llegada de la guerra civil que casi acaba con ellos.¿Qué pasó realmente durante la Danza de dragones?",
    "year": 2020,
    "authors": [
      "George R.r. Martin"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 125
  },
  {
    "title": "EL ENCUADERNADOR",
    "isbn": "9788401024290",
    "synopsis": "Un relato de deseos enterrados y traiciones indescriptibles.Una historia de amor que desafía los límites.Una novela mágica e inolvidable.Imagina que los libros no solo contienen historias.Imagina que puedes ocultar entre sus páginas tus mayores miedos, tu dolor más profundo, tus secretos más oscuros. A todo el mundo. Incluso a ti mismo. Para siempre.Emmett Farmer, después de un largo día de trabajo en el campo, recibe una misteriosa carta que le cita a incorporarse como aprendiz de encuadernador. Es una profesión que despierta miedo y superstición en su entorno.",
    "year": 2020,
    "authors": [
      "Bridget Collins"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 126
  },
  {
    "title": "CAMINO SIN RETORNO",
    "isbn": "9788498891232",
    "synopsis": "Lo recuerdo, pensó Geralt, lo recuerdo. Sí, allí, en las escaleras resbaladizas por la sangre del castillo de Rhys-Run, donde lucharon hombro con hombro, él y ella, el Lobo y la Gata, dos máquinas de dar muerte, inhumanas en su rapidez y crueldad porque los habían arrastrado hasta el final, enloquecidos, apoyados contra la pared. Sí, entonces los nilfgaardianos retrocedieron, llenos de miedo, ante el brillo y el silbido de sus hojas, y ellos fueron bajando despacio, hacia abajo por las escaleras del castillo de Rhys-Run, húmedas de sangre. Bajaron apoyados el uno en el otro, unidos, y delante de ellos caminaba la muerte, la muerte en forma de dos blancas hojas de espada. El frío y tranquilo Lobo y la loca Gata. El brillo de las hojas, el grito, la sangre, la muerte... Sí, entonces... Entonces... Ciri volvió a echarse los cabellos hacia atrás y entre sus mechones cenicientos brilló la nívea blancura de la ancha banda de su sien.",
    "year": 2019,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 132
  },
  {
    "title": "UNA EDUCACION MORTAL",
    "isbn": "9788416517411",
    "synopsis": "Inaugurando una nueva trilogía, la autora superventas de \"Un cuento oscuro\" y \"Un mundo helado\" nos abre las puertas a una peligrosa escuela de magia donde cometer errores es sinónimo de una muerte segura. hasta que una chica empieza a reescribir las reglas del juego. Entra en una escuela de magia diferente a cualquiera que hayas conocido antes. En ella no hay profesores ni vacaciones, las amistades son pura estrategia y las probabilidades de sobrevivir nunca son las mismas. Cuando estás dentro, solo hay dos maneras de salir: o te gradúas o mueres. El Higgins está preparada como nadie para hacer frente a los muchos peligros de la escuela. Puede que no tenga aliados, pero posee una fuerza oscura lo suficientemente poderosa para elevar montañas y aniquilar a millones, por no mencionar que puede destruir fácilmente a los innumerables monstruos que merodean por ella. Solo que, accidentalmente, podría matar también al resto de estudiantes.",
    "year": 2021,
    "authors": [
      "Naomi Novik"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 137
  },
  {
    "title": "MEMORIAS DEL HIELO (SAGA MALAZ: EL LIBRO DE LOS CAIDOS 3)",
    "isbn": "9788466662666",
    "synopsis": "Memorias del hieloes la tercera entrega de la saga «Malaz: El Libro de los Caídos», la decalogía originalmente publicada entre 1999 y 2011 que ha convertido al escritor canadiense Steven Erikson en una de las mayores voces de la fantasía épica contemporánea. Desde entonces, esta obra maestra de la imaginación está considerada una de las series más ambiciosas del género de los últimos años.Una fuerza aterradora ha surgido en el continente asolado de Genabackis. Como una marea de sangre corrompida, el Dominio Painita cruza el continente como lava hirviente que consume a todos los que no escuchan la palabra de su profeta, el Vidente Painita. En su camino se interpone una alianza incómoda: la hueste de Dujek Unbrazo y los veteranos Abrasapuentes de Whiskeyjack, junto con antiguos adversarios: el caudillo Caladan Brood, Anomander Rake y sus tiste andii.",
    "year": 2018,
    "authors": [
      "Steven Erikson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 144
  },
  {
    "title": "EL ULTIMO DESEO (SAGA GERALT DE RIVIA 1)(RUSTICA)",
    "isbn": "9788498891270",
    "synopsis": "Geralt de Rivia, brujo y mutante sobrehumano, se gana la vida como cazador de monstruos en una tierra de magia y maravilla: con sus dos espadas al hombro -la de acero para hombres, y la de plata para bestias- da cuenta de estriges, manticoras, grifos, vampiros, quimeras y lobisomes, pero sólo cuando amenazan la paz. Irónico, cínico, descreído y siempre errante, sus pasos lo llevan de pueblo en pueblo ofreciendo sus servicios, hallando las más de las veces que los auténticos monstruos se esconden bajo rostros humanos. En su camino sorteará intrigas, elegirá el mal menor, debatirá cuestiones de precio, hollará el confín del mundo y realizará su último deseo: así comienzan las aventuras del brujo Geralt de Rivia. Andrzej Sapkowski es el gran renovador de la literatura fantástica de nuestros tiempos, un genio del lenguaje y la caracterización cuya prosa ya ha hechizado a millones de lectores en todo el mundo.",
    "year": 2019,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 151
  },
  {
    "title": "UN POCO DE ODIO (TRILOGIA LA ERA DE LA LOCURA 1) (MUNDO DE LA PRI MERA LEY)",
    "isbn": "9788491818038",
    "synopsis": "\"Un poco de odio\", la esperada nueva novela de Joe Abercrombie, que da inicio a la trilogía \"La era de la locura\", nos lleva de nuevo al mundo de \"La Primera Ley\".Años después, la era de la máquina está llegando al Círculo del Mundo, pero la era de la magia se niega a morir. Las chimeneas de la industria se elevan sobre Adua y el mundo bulle de nuevas oportunidades. Pero las viejas rencillas no se han olvidado.En las castigadas fronteras de Angland, Leo dan Brock lucha por conseguir la fama en el campo de batalla y derrotar a los ejércitos de Stour Ocaso. Para ello espera recibir ayuda de la corona, pero es mejor no contar con el hijo del rey Jezal, el irresponsable príncipe Orso.Savine dan Glokta (influyente inversora e hija del hombre más temido de la Unión) planea llegar a la cumbre del montón de escoria de la sociedad empleando los medios que sean precisos.",
    "year": 2020,
    "authors": [
      "Joe Abercrombie"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 153
  },
  {
    "title": "ASSASSIN S CREED: REVELATIONS",
    "isbn": "9788445008263",
    "synopsis": "La novela oficial de uno de los mejores videojuegos del mundo (Ubisoft).El Maestro Assassin Ezio Auditore se embarca en un viaje para encontrar la biblioteca perdida de Altaïr, que tal vez tenga la clave para acabar con los Templarios. Sin esperarlo, descubre que la biblioteca también contiene un secreto que pueda ayudar a los Templarios a hacerse con el control del destino de la humanidad.Para acceder a la biblioteca se precisan cinco llaves que Ezio deberá encontrar en Constantinopla, donde los Templarios suponen una gran amenaza para el imperio otomano. Ezio deberá seguir los pasos de su predecesor, Altaïr, y derrotar por fin a los Templarios.",
    "year": 2020,
    "authors": [
      "Oliver Bowden"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 155
  },
  {
    "title": "EL GUERRERO DE LOS ALTAII",
    "isbn": "9788445008225",
    "synopsis": "Una historia inédita del maestro de la fantasía épica Robert Jordan, escrita antes de LA RUEDA DEL TIEMPO. Soy Wulfgar, guerrero de los Altaii. Acércate y te contaré la historia de Lanta, la ciudad de las doce puertas, la Inconquistable, la Perla del Llano. Te hablaré de los Tronos Gemelos de Lanta, y de las dos reinas que los ocuparon. Te hablaré de Morassa, de Brecon e Ivo, quienes nos lideraron hacia la guerra. De los Encumbrados y de los poderes que cubrían el Llano en el Año del Lagarto de Piedra. Acércate y escucha.",
    "year": 2020,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 157
  },
  {
    "title": "EL PRINCIPE CAUTIVO (SAGA EL PRINCIPE CAUTIVO 1)",
    "isbn": "9788416224982",
    "synopsis": "Damen es un heroico guerrero y el legítimo heredero del trono de Akielos. Pero cuando su medio hermano se hace con el poder, Damen es capturado y vendido como esclavo de placer al príncipe de una nación enemiga. Su nuevo amo, Laurent, es atractivo, manipulador y mortífero: es decir, encarna lo peor de Vere, su país.",
    "year": 2018,
    "authors": [
      "C. S. Pacat"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 164
  },
  {
    "title": "BRAZALES DE DUELO (SAGA NACIDOS DE LA BRUMA 6)",
    "isbn": "9788466659628",
    "synopsis": "Brazales de Duelo es el sexto libro de la saga «Nacidos de la Bruma [Mistborn]», una obra iniciada conEl imperio final y parte imprescindible del Cosmere, el universo destinado a convertirse en la serie más extensa y fascinante jamás escrita en el ámbito de la fantasía épica.La cuenca de Elendel es un polvorín. El descontento de los trabajadores se suma a las diferencias irreconciliables entre la capital y las demás ciudades de la cuenca; Elendel asegura gobernarlas mientras sus habitantes denuncian la opresión a la que se sienten sometidos. De pronto, llega a oídos de Waxillium Ladrian que un académico kandra podría haber localizado los legendarios Brazales de Duelo, un arma capaz de sembrar la destrucción y dar al traste con el actual equilibrio de poder imperante en la cuenca.Pero perseguir mitos no se cuenta entre las atribulaciones de un representante de la ley como él, acuciado por problemas más inmediatos.",
    "year": 2017,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 170
  },
  {
    "title": "UNA VENGANZA MORTAL",
    "isbn": "9788416517596",
    "synopsis": "NO TE PIERDAS UNA DE LAS SERIES MÇS EXITOSASáDE V. E. SCHWAB, LAá AUTORA BEST SELLER DEáLA VIDA INVISIBLE DE ADDIE LARUE.Aliados.Enemigos.Villanos.ExtraOrdinarios.Eli Ever y Victor Vale eran simples estudiantes de medicinaácuando descubrieron que las experiencias cercanas a la muerteápueden manifestar capacidades extraordinarias si se danáciertas condiciones.Fueron muy amigos, luego se convirtieron en rivales y, finalmente,áse volvieron enemigos.Estuvieron muertos, revivieron, y más tarde. Eli mató a Victoráde una vez por todas.Al menos, eso creía. Pero Sydney Clarke no estuvo de acuerdo yáusó su propio superpoder para inclinar la balanza. Pero cuandoáMarcella Reggins entra en escena, las cosas en la ciudad deáMerit se complican aún más. Ella no necesita alianzas. Y haráátodo lo que este al alcance de su mano para sacar ventaja deálos dos ExtraOrdinarios más poderosos: Eli Ever y Victor Vale.Si puede haber vida despues de la muerte.",
    "year": 2022,
    "authors": [
      "V.e. Schwab"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 177
  },
  {
    "title": "UN CRIMEN CIENTIFICO Y OTROS CUENTOS",
    "isbn": "9788483810248",
    "synopsis": "Un heterodoxo del cuento español: fantasía y ciencia ficción en el siglo XIX .El lector tiene entre sus manos la puerta de entrada a un singularísimo universo: estrafalarios científicos de aviesas intenciones, charlatanes que proclaman a los cuatro vientos las bondades de disparatados métodos curativos, orangutanes y bicéfalos trasmutados en protagonistas del Madrid del último tercio del siglo XIX, o frailes que enloquecen tras beber un vino de extrañas propiedades. Con una prosa transparente y ágil, nos sitúa en ese lugar donde se encuentran el escalofrío, la carcajada y la perplejidad, y que ofrece una visión muy particular, no siempre cómoda hoy, del contexto político y cultural en el que fueron concebidos. Un crimen científico constituye una excepcional oportunidad para aproximarse al imaginario narrativo de José Fernández Bremón, puesto que, si bien algunos de estos relatos han aparecido en varias antologías recientes.",
    "year": 2008,
    "authors": [
      "Jose Fernandez Bremon"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 198
  },
  {
    "title": "LA SANGRE DE LOS ELFOS (SAGA GERALT DE RIVIA 3) (EDICION COLECCIO NISTA)",
    "isbn": "9788498890457",
    "synopsis": "\"En verdad os digo que se acerca el tiempo de la espada y el hacha, la época de la tormenta salvaje. Se acerca el Tiempo del Invierno Blanco y de la Luz Blanca. El Tiempo de la Locura y el Tiempo del Odio, el Tiempo del Fin. El mundo morirá entre la escarcha y resucitará de nuevo junto con el nuevo sol. Resucitará de entre la Antigua Sangre, de Hen Ichaer, de la semilla sembrada. De la semilla que no germina sino que estalla en llamas. ¡Así será! ¡Contemplad las señales! Qué señales sean, yo os diré: primero se derramará sobre la tierra la sangre de los Aen Seidhe, la Sangre de los Elfos.\"Aen Ithlinnespeath, profecía de Ithlinne Aegli aep AevenienAndrzej Sapkowski es el gran renovador de la literatura fantástica de nuestros tiempos, un genio del lenguaje y la caracterización cuya prosa ya ha hechizado a millones de lectores en todo el mundo.",
    "year": 2010,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 201
  },
  {
    "title": "EL TEMPLO DE LOS VIENTOS: LA ESPADA DE LA VERDAD (VOL. 8)",
    "isbn": "9788448032319",
    "synopsis": ".El emperador Jagang desata una terrible plaga de peste contra la Tierra Central. Para salvar miles de vidas inocentes, tanto Richard como Kahlan deberán tomar una difícil decisión y sacrificarse. Los espíritus, buenos y malos, están dispuestos a ayudarlos. Pero todo tiene un precio, y en el mundo de los espíritus mora el peor enemigo de Richard: Rahl el Oscuro, su propio padre. ¿Qué exigirá a cambio de ayudar a Richard en su búsqueda de un remedio para la plaga?",
    "year": 2004,
    "authors": [
      "Terry Goodkind"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 206
  },
  {
    "title": "LAS TUMBAS DE ATUAN",
    "isbn": "9788445012222",
    "synopsis": "Han pasado más de diez años desde que Ged se enfrentara a su propia sombra en Un mago de Terramar. Capaz ahora de actuar en beneficio de otros, decide recobrar la runa de la unión, la mitad perdida del anillo de Erreth-Akbe, guardado, se cuenta, en las Tumbas de Atuan. La sacerdotisa de las Tumbas es Arha, que lleva el significativo apodo de la Devorada, y que no tiene identidad, pues la ha perdido para ponerse al servicio de los Sin Nombre, las potestades tenebrosas de Terramar.",
    "year": 2022,
    "authors": [
      "Ursula K. Le Guin"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 207
  },
  {
    "title": "GALLANT",
    "isbn": "9788416517664",
    "synopsis": "TODO PROYECTA UNA SOMBRA. INCLUSO EL MUNDO EN EL QUE VIVIMOS. Y COMO OCURRE CON TODA SOMBRA, HAY UN LUGAR DONDE ESTA SE UNE CON LO QUE LA GENERA. Lo único que Olivia Prior conserva de su pasado es el diario de su madre. Entonces recibe una carta invitándola a regresar a Gallant, su hogar. Pero cuando llega, nadie la está esperando.Sin embargo, Olivia no está dispuesta a marcharse. No importa si su primo Matthew es desagradable con ella, o si ve espíritus rondando por los pasillos.Olivia sabe que Gallant oculta secretos, y está decidida a descubrirlos. Cuando cruza una pared en ruinas, llega a un lugar que es Gallant, pero que a la vez no lo es.La mansión se está desmoronando, los espíritus son sólidos y una misteriosa figura lo gobierna todo.Olivia siempre ha querido pertenecer a algún lugar, pero ¿tomará su lugar como una Prior, protegiendo a nuestro mundo contra el Señor de la Casa?",
    "year": 2022,
    "authors": [
      "V.e. Schwab"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 208
  },
  {
    "title": "EL CIRCO DE LA NOCHE",
    "isbn": "9788416517282",
    "synopsis": "Dos magos enfrentados por el destino compiten en un desafío mortal en El circo de la noche, el hipnótico best seller que ha capturado la imaginación del mundo entero.El circo llega sin avisar. No viene precedido de ningún anuncio. De pronto está allí, donde hasta el día anterior no había nada. Dentro de las carpas de rayas blancas y negras, se suceden eventos únicos y deslumbrantes. Se llama Le Cirque des Rêves, el circo de los sueños, y solo abre por las noches.Pero, tras bambalinas, se desarrolla una feroz rivalidad: un duelo entre dos jóvenes magos, Celia y Marco, que han sido entrenados desde pequeños por sus instructores con este fin. Aunque no lo saben, este es un juego en el que solo uno puede sobrevivir.",
    "year": 2020,
    "authors": [
      "Erin Morgenstern"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 217
  },
  {
    "title": "EL ARCHIVO Nº1/2",
    "isbn": "9788445007976",
    "synopsis": "La nueva serie de la creadora de Sombras de MagiaImagina un lugar donde los muertos descansan como libros en bibliotecas. Cada cuerpo tiene una historia que contar, una vida en imágenes que solo los Bibliotecarios pueden leer. Los muertos reciben el nombre de Historias. Y el vasto reino en el que descansan es el Archivo. En esta novela hermosa y oscura de persecución y misterio, Victoria Schwab trata sobre la delgada línea entre el pasado y el presente, el amor y el dolor, la confianza y la traición, las pérdidas insoportables y la lucha hacia la redención.",
    "year": 2020,
    "authors": [
      "V.e. Schwab"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 222
  },
  {
    "title": "LAS PUERTAS DE LA CASA DE LA MUERTE (SAGA MALAZ: EL LIBRO DE LOS CAIDOS 2)",
    "isbn": "9788466660952",
    "synopsis": "Las puertas de la Casa de la Muerte es el segundo volumen de la saga «Malaz: El Libro de los Caídos», decalogía originalmente publicada entre 1999 y 2011 que ya es considerada una de las series más ambiciosas del género y que ha convertido al escritor canadiense Steven Erikson en una de las mayores voces de la fantasía épica contemporánea.Debilitado por los acontecimientos en Darujhistan, el Imperio de Malaz se halla al borde de la anarquía. En el vasto dominio de las Siete Ciudades, en el desierto Santo Raraku, la vidente Sha''ik y sus seguidores se preparan para el Torbellino, la sublevación profetizada desde hace mucho tiempo. Será un brote de fanatismo que envolverá al imperio en un salvajismo y una sed de sangre sin precedentes. Estallará uno de los conflictos más sangrientos de su historia y surgirán nuevos destinos y leyendas.En las minas de otaralita, Felisin sueña con vengarse de su hermana, que la condenó a una vida de esclava.",
    "year": 2017,
    "authors": [
      "Steven Erikson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 232
  },
  {
    "title": "MAREAS DE MEDIANOCHE (SAGA MALAZ: EL LIBRO DE LOS CAIDOS 5)",
    "isbn": "9788417347222",
    "synopsis": "Mareas de Medianochees el quinto volumen de la saga «Malaz: El Libro de los Caídos», la decalogía originalmente publicada entre 1999 y 2011 que ha convertido al escritor canadiense Steven Erikson en una de las mayores voces de la fantasía épica contemporánea. Desde entonces, esta obra maestra de la imaginación está considerada una de las series más ambiciosas del género de los últimos años.Después de décadas de guerras intestinas, las tribus de los Tiste Edur al fin se han unido bajo el mando del Rey Warlock.Hay paz, pero el precio ha sido terrible: un pacto hecho con un poder oculto cuyos motivos son, en el mejor de los casos, sospechosos, y, en el peor, mortales. Al sur, el rapaz reino de Lether, impaciente por ver cumplido el papel que profetizaron para él largo tiempo atrás como imperio renacido, ha esclavizado a sus vecinos menos civilizados. Es decir, a todos salvo a los Tiste Edur.",
    "year": 2018,
    "authors": [
      "Steven Erikson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 234
  },
  {
    "title": "WORLD OF WARCRAFT: MAREAS TENEBROSAS",
    "isbn": "9788490242834",
    "synopsis": "Contiene World Of Warcraft: Tides Of Darkness HC USA El viejo Campeón de Ventormenta, Anduin Lothar, ha dejado atrás su destrozada patria para conducir a su pueblo hasta el otro lado del Gran Mar, en las costas de Lordaeron. Allí, con la ayuda del noble rey Terenas, sella una gran alianza con otras naciones humanas. Pero este pacto podría no ser suficiente para impedir el salvaje asalto de la feroz Horda.",
    "year": 2013,
    "authors": [
      "Aaron Rosenberg"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 248
  },
  {
    "title": "LA CASA MALDITA Y OTROS CASOS INSOLITOS",
    "isbn": "9788494428708",
    "synopsis": "Obstinado soñador, figura de culto en la bohemia de su época, Pedro Escamilla supo plasmar en sus relatos sus más apasionadas e inquietantes visiones con la intensidad de las obras de otros célebres maestros como Bécquer, Erckmann, Hoffmann o Poe. La presencia de temas clásicos del género moderno de terror, como la aparición del doble, la lógica indescifrable de ciertas fatídicas casualidades o una densa atmósfera de terror psicológico que envuelve a los protagonistas de sus historias, dotan a su obra de una poderosa y vigente actualidad.",
    "year": 2015,
    "authors": [
      "Pedro Escamilla"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 250
  },
  {
    "title": "MATERIAL SENSIBLE",
    "isbn": "9788498387360",
    "synopsis": "Una antología que concentra todo el potencial fantasioso y onírico de Gaiman: historias de terror y de fantasmas, ficción especulativa y cuentos de hadas, fábulas perversas y versos sorprendentes.Con una enorme legión de fieles lectores en todo el mundo, Neil Gaiman está considerado uno de los escritores de imaginación más fértil y perturbadora de la actualidad.Como es característico en él, el mundo sensible no es más que un mero velo o una ilusión tras la cual se despliega un sinfín de realidades paralelas y mundos alternativos, casi siempre amenazantes y ominosos. En la mente creativa de Gaiman, todo es posible: laberintos lunares, amigos imaginarios de carne y hueso, iglús fabricados con libros, piratas muy peculiares, caseras asesinas, objetos hechizados, tarjetas de felicitación que alteran el espacio-tiempo...",
    "year": 2016,
    "authors": [
      "Neil Gaiman"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 253
  },
  {
    "title": "ELANTRIS (10º ANIVERSARIO)",
    "isbn": "9788466658843",
    "synopsis": "Una novela imprescindible para los amantes de la fantasía épica. Por el consagrado autor del género Brandon Sanderson.«La más bella novela de fantasía que se escribirá en muchos años.»Orson Scott Card, autor de El juego de EnderBienvenidos a la ciudad de Elantris, la poderosa y bella capital de Arelon llamada «la ciudad de los dioses».Antaño famosa sede de inmortales, lugar repleto de poderosa magia, Elantris ha caído en desgracia. Ahora solo acoge a los nuevos «muertos en vida», postrados en una insufrible «no-vida» tras una misteriosa y terrible transformación.Un matrimonio de Estado destinado a unir los reinos de Arelon y Teod se frustra, ya que el novio, Raoden, el príncipe de Arelon, sufre inesperadamente la Transformación, se convierte en un «muerto en vida» y debe refugiarse en Elantris. Su reciente esposa, la princesa Sarene de Teod, creyéndolo muerto, se ve obligada a incorporarse a la vida de Arelon y su nueva capital, Kae.",
    "year": 2016,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 254
  },
  {
    "title": "LOS DIOSES DE MARTE: BAJO LAS LUNAS DE MARTE 2",
    "isbn": "9788492492718",
    "synopsis": "Si en Una princesa de Marte dejamos a John Carter de vuelta en la Tierra de un modo tan misterioso como llego´ al Planeta Rojo por primera vez, aquí´ le vemos de vuelta al mundo de sus sueños, Barsoom, tras una prolongada estancia en la Tierra que se produce tras el final abierto de la primera novela de la Serie Marciana. Ahora John Carter se encuentra en el Paraíso de los marcianos, ante las aguas del misterioso río Iss, el mismo que recorren los habitantes del Planeta Rojo cuando desean reunirse voluntariamente con la diosa Issus. Pero no todo es tan amable como les han querido hacer ver: la diosa Issus es una diosa de la maldad que no desea otra cosa que los cuerpos de sus adoradores para practicar con ellos unos rituales que están más allá de la comprensión y la caridad humana.",
    "year": 2012,
    "authors": [
      "Edgar Rice Burroughs"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 255
  },
  {
    "title": "PIRANESI",
    "isbn": "9788418363283",
    "synopsis": "Vuelve la autora deJonathan Strange y el señor Norrell con una novela hipnótica ambientada en una realidad onírica.La casa de Piranesi no es un edificio cualquiera: sus habitaciones son monumentales, con paredes llenas de miles de estatuas, y sus pasillos, interminables. Dentro del dédalo de corredores hay un océano aprisionado en el que las olas retumban y las mareas inundan los aposentos. Pero Piranesi no tiene miedo: comprende las embestidas del mar igual que el patrón del laberinto, mientras explora los límites de su mundo y avanza, con la ayuda de un hombre llamado El Otro, en una investigación científica para alcanzar El Gran Conocimiento Secreto.La crítica ha dicho.«Nos recuerda el poder de la ficción para llevarnos a otro mundo y ampliar así la comprensión del nuestro. [.] Supera las expectativas en todo.»The Guardian«Como un sueño febril: desorientador, fascinante, persistentemente extraño.",
    "year": 2021,
    "authors": [
      "Susanna Clarke"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 270
  },
  {
    "title": "UNA CANCION SALVAJE",
    "isbn": "9788416517626",
    "synopsis": "Kate Harker quiere ser despiadada como su padre. Tras cinco años en los que pasó por seis internados, al fin regresa a casa para demostrar que puede serlo.August Flynn quiere ser humano. Pero no lo es. Es un monstruo, capaz de robar almas con una canción. Es uno de los tres monstruos más poderosos de una ciudad plagada de estas criaturas. El arma secreta de su propio padre.Su ciudad está desintegrándose. Su ciudad está dividida.Kate y August son los únicos que pueden ver ambos lados, los únicos que podrían hacer algo. Pero ¿cómo te decides a ser héroe o villano cuando es tan difícil distinguirlos?",
    "year": 2021,
    "authors": [
      "V.e. Schwab"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 271
  },
  {
    "title": "LAS BRUJAS DEL AYER Y DEL MAÑANA",
    "isbn": "9788418557682",
    "synopsis": "GANADORA A LA MEJOR NOVELA DEL AÑO DE LOS BRITISH FANTASY AWARDS.LA NOVELA DE FANTASÍA MÇS ESPERADA DE LOS ÚLTIMOS AÑOS.Una profunda historia sobre la resistencia, la sororidad y el derecho a voto ambientada en una versión alternativa de la Nueva Inglaterra del siglo XIX.En 1893 ya no hay brujas. En el pasado sí que las había, en esa epoca oscura e inhóspita antes de que empezasen a encenderse las hogueras. Ahora, la brujería es poco más que hechizos de amas de casa y canciones infantiles. Si la mujer moderna quiere algo de poder, las urnas son el único lugar donde puede llegar a conseguirlo.Pero James Juniper, Agnes Amaranth y Beatrice Belladonna, las hermanas Eastwood, se unen a las sufragistas de Nueva Salem y empiezan a buscar las palabras y los componentes olvidadas capaces de convertir la revolución de las mujeres en la revolución de las brujas.",
    "year": 2022,
    "authors": [
      "Alix E. Harrow"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 276
  },
  {
    "title": "LA RUEDA DEL TIEMPO Nº 14/14 UN RECUERDO DE LUZ",
    "isbn": "9788445007136",
    "synopsis": "Última entrega de la mítica saga de Fantasía.Los dirigentes de las naciones se reúnen en Campo de Merrilor para apoyar a Rand al''Thor o frenar su plan de romper sellos de la prisión del Oscuro, algo que podría ser una señal de locura o la última esperanza de la humanidad. En Andor, los trollocs invaden Caemlyn. En el Sueño del Lobo, Perrin Aybara combate contra Verdugo.Mientras se aproxima a Ebou Dar, Mat Cauthon hace planes para visitar a su esposa Tuonm ahora Fortuona, emperatriz de Seanchan. Toda la humanidad está en peligro, y el resultado se decidirá en Shayol Ghul. La Rueda gira, y la era actual llega a su fin. La Última Batalla determinará el destino del mundo.",
    "year": 2021,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 277
  },
  {
    "title": "CTS ASSASSIN S CREED 1: RENAISSANCE",
    "isbn": "9788445010617",
    "synopsis": "Una novela del universo interactivo de Assassin''s Creed a precio especial.«Buscaré la venganza contra aquellos que traicionaron a mi familia. Soy Ezio Auditore di Firenze. Soy un Asesino…» Tras sufrir la traición de las familias que gobiernan Florencia, Venecia y Roma en la Italia del Renacimiento, el joven Ezio Auditore se embarca en una épica lucha para poner fin a la corrupción y restaurar el honor de su familia. Para ello deberá aprender el arte de la muerte.En su camino de venganza y lucha se encontrará con las grandiosas mentes de Leonardo da Vinci y Maquiavelo; deberá decidir entre el amor y su destino, y descubrirá que este último es mucho más complejo y elevado de lo que nunca imaginó. Para sus aliados, Ezio se convertirá en la fuerza que les guiará en la búsqueda de la libertad y la justicia. Para sus enemigos, en una amenaza consagrada a la destrucción de los tiranos que abusan del pueblo italiano.",
    "year": 2022,
    "authors": [
      "Oliver Bowden"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 283
  },
  {
    "title": "EL DARICO GRIS",
    "isbn": "9788412382785",
    "synopsis": "«Mi pueblo fue el primero en caminar por el mundo, compartiendo Muriath con los demonios, mucho antes de la existencia de zarefíes, kalastys y eldos. Y por supuesto, miles de ágaras antes de la aparición de los humanos». Asthaluss y Muriath son dos mundos gemelos, y la raza humana los habita ambos. Asthaluss es la Tierra que conocemos, pero Muriath se encuentra más allá de cualquier realidad imaginable: es un lugar antaño poblado por dioses y demonios, cuyos habitantes poseen dones extraordinarios, y en el que los humanos conviven con otras razas, entre ellas los dáricos, los primeros seres en haber caminado sobre él. El día de su cumpleaños, Alhanna es transportada de Asthaluss a Muriath, donde aparece ante Kishur, un dárico que querrá a protegerla a toda costa al sentir que los une una inexplicable conexión.",
    "year": 2022,
    "authors": [
      "Eva Amuedo"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 286
  },
  {
    "title": "EL ULTIMO GRADUADO",
    "isbn": "9788416517671",
    "synopsis": "La amenaza de la graduación cobra un peso significativo al tiempo que la innovadora trilogía de Naomi Novik, superventas del New York Times, continúa con la asombrosa secuela de \"Una educación mortal\". «El conocimiento otorga protección.» Ese es el lema oficial de la Escolomancia. Supongo que podríamos decir que es cierto. El problema es que aquí resulta muy difícil aprender, por lo que la protección de la que disponemos es más bien escasa. Nuestro estimado colegio hace todo lo posible por devorar a sus alumnos, pero ahora que estoy en último curso y me he agenciado unos cuantos aliados, ha desarrollado de repente un antojo de lo más particular por mí. Incluso si consigo sobrevivir a las interminables oleadas de maleficaria con las que me obsequia entremedias de los agotadores proyectos para clase, no tengo ni idea de cómo mis aliados y yo vamos a salir vivos del salón de grados.",
    "year": 2022,
    "authors": [
      "Naomi Novik"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 288
  },
  {
    "title": "LA RUEDA DEL TIEMPO Nº 13/14 TORRES DE MEDIANOCHE",
    "isbn": "9788445007129",
    "synopsis": "Penúltima entrega de la saga fantástica.La Última Batalla ha comenzado. Los Capas Blancas, un asesino de lobos y las responsabilidades del liderazgo acosan a Perrin Aybara. Debe buscar respuestas en el Tel’aran’rhiod a fin de superar estos obstáculos, controlar al lobo que lleva dentro y no perder para siempre su condición humana.Entre tanto, Matrim Cauthon se dispone a afrontar el reto más difícil de su vida: los seres del otro lado de los marcos de piedra, los alfi nios y los elfi nios. La Torre de Ghenjei espera y sus secretos revelarán el destino de una persona amiga que lleva perdida mucho tiempo. Dovie’andi se tovya sagain. Es hora de lanzar los dados.",
    "year": 2021,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 293
  },
  {
    "title": "CANALLAS (ROGUES)",
    "isbn": "9788409333462",
    "synopsis": "Este libro ha sido diseñado específicamente para el Ciclo Formativo de Formación Profesional \"Técnico Superior en Sonido para Audiovisuales y Espectáculos\", aunque será también un manual imprescindible para cualquier usuario interesado en las disciplinas relacionadas con el audio, especialmente en ciertos aspectos de la rama de la electroacústica.Todos los capítulos se abordan presentando los contenidos teóricos necesarios desde un punto de vista eminentemente práctico, de forma que al profesor de la asignatura le resulte casi consecuente una inmediata presentación de ejemplos y ejercicios prácticos de laboratorio o una resolución de problemas y ejercicios sencillos en clase. Al final del libro profundizamos contenido con más de veinte ejercicios de autoevaluación, por capítulo, con su correspondiente solucionario.",
    "year": 2021,
    "authors": [
      "George R.r. Martin"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 295
  },
  {
    "title": "LA HIJA DE LOS HUESOS (TRILOGIA EL IMPERIO HUNDIDO)",
    "isbn": "9788418711305",
    "synopsis": "En todas las islas del Imperio, se extrae detrás de la oreja de cada niño un trozo de hueso, durante un ritual que con demasiada frecuencia es fatal. Desde su palacio, el emperador utiliza estos preciosos fragmentos para crear y controlar formidables quimeras animales, los constructos que mantienen la ley y el orden. Pero su autoridad flaquea y la rebelión ruge por todas partes. Lin ha perdido sus recuerdos y pasa sus días en el enorme palacio lleno de puertas cerradas y oscuros secretos. Cuando su padre se niega a reconocerla como heredera del trono, ella promete demostrar su valía dominando el arte prohibido sobre la magia de los huesos. Magia que tiene un precio. Cuando la revolución golpee las puertas del palacio, Lin tendrá que decidir hasta dónde está dispuesta a llegar para reclamar su herencia y salvar a su pueblo",
    "year": 2022,
    "authors": [
      "Andrea Stewart"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 298
  },
  {
    "title": "LA TRAICION DE MONTVERRE",
    "isbn": "9788416517718",
    "synopsis": "Si tu vida estuviera erigida sobre una mentira, ¿lo arriesgarías todo para desvelar la verdad?En Montverre, una antigua academia de élite oculta en las montañas, entrenan a los mejores y más brillantes miembros de la sociedad para alcanzar la excelencia en el «grand jeu», una competición arcana y misteriosa que combina música, arte, matemáticas, poesía y filosofía. Léo Martin destacaba en Montverre, pero perdió la pasión por las actividades académicas después de una violenta tragedia. Recurrió a la política y se convirtió en una estrella emergente en el partido gobernante, hasta que una acción de buena conciencia le costó la carrera. Ahora está de vuelta en Montverre, exiliado, con un destino incierto.No obstante, este mundo elitista de aprendizaje que Léo disfrutaba en el pasado no es el lugar que él recuerda.",
    "year": 2022,
    "authors": [
      "Bridget Collins"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 300
  },
  {
    "title": "LA CIUDAD JUSTA",
    "isbn": "9788412319682",
    "synopsis": "Atenea, diosa griega de la sabiduría, ha dado vida a la República de Platón en una isla perdida del Mediterráneo. Allí reúne a filósofos de todas las épocas, niños que fueron esclavos y robots encargados del trabajo duro.En La Ciudad Justa, Simmea, una niña brillante, demostrará todo su potencial; Maia, una antigua dama victoriana, deberá encontrar su verdadero lugar y Apolo comprenderá por fin el valor de la vida humana.En esta ciudad de las ideas y el conocimiento todos se esforzarán por alcanzar la excelencia siguiendo al pie de la letra las palabras de Platón… Todo, menos Sócrates, que hará las preguntas que nadie quiere responder.",
    "year": 2021,
    "authors": [
      "Jo Walton"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 302
  },
  {
    "title": "UN CUENTO OSCURO",
    "isbn": "9788408151487",
    "synopsis": "«Tiene todo lo que me gusta: una gran heroína,mitos y leyendas, y giros sorprendentes.»Cassandra ClareAgnieszka tiene un don: es capaz de romper, manchar o perder cualquiercosa que lleve puesta en cuestión de segundos. Vive en el vallecon su familia y es feliz en su pequeño y asilvestrado hogar. Pero la malignay retorcida presencia del Bosque se cierne desde hace años sobretodos ellos. Para protegerse, el pueblo confía en el poder de un misteriosomago conocido como el Dragón, el único capaz de controlar consu magia el poder del Bosque. A cambio de protección, pide una solacosa: cada diez años podrá escoger a una chica y se la llevará a su torre, un destino casi tan terrible como caer presa del Bosque.El día de la elección se acerca y Agnieszka tiene miedo. Sabe—dehecho todo el mundo sabe—que el Dragón escogerá a Kasia, la másbonita, la más valiente de todas las aspirantes. Y, también, la mejor amigade Agnieszka.",
    "year": 2016,
    "authors": [
      "Naomi Novik"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 321
  },
  {
    "title": "LUX PERPETUA (GUERRAS HUSITAS 3)",
    "isbn": "9788498890983",
    "synopsis": "El Anticristo, muy señores míos, querido público, será de la estirpe de Dan. Reinmar de Bielau, llamado Reynevan, se encuentra en una encrucijada. Por un lado, el médico y alquimista educado en Praga se ha convertido en un participante de importancia en la revolución husita contra el clero y la nobleza, un movimiento que ha impuesto su ley en Bohemia y Moravia, y que amenaza con extenderse por toda Silesia, Sajonia y Polonia hasta el mar Báltico.",
    "year": 2016,
    "authors": [
      "Andrzej Sapkowski"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 326
  },
  {
    "title": "LOS JARDINES DE LA LUNA (SAGA MALAZ: EL LIBRO DE LOS CAIDOS 1)",
    "isbn": "9788466660877",
    "synopsis": "Los jardines de la Luna es el brillante inicio de la saga «Malaz: El Libro de los Caídos», la decalogía originalmente publicada entre 1999 y 2011 que ya es considerada una de las series más ambiciosas del género y que ha convertido al escritor canadiense Steven Erikson en una de las mayores voces de la fantasía épica contemporánea.Tras guerras interminables y amargas luchas internas, el descontento se ha apoderado del Imperio de Malaz. Incluso las tropas imperiales, siempre ansiosas por derramar sangre, necesitan un respiro.",
    "year": 2017,
    "authors": [
      "Steven Erikson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 327
  },
  {
    "title": "EL SEÑOR DEL CAOS Nº 06/14",
    "isbn": "9788445007051",
    "synopsis": "La Rueda del Tiempo de Robert Jordan es la saga de fantasía más importante de los últimos años.Rand se esfuerza por unir a las naciones para combatir al Oscuro al tiempo que se ve obligado a sortear las trampas que los Renegados tienden a la desprevenida raza humana. Pero además tiene que enfrentarse a los Hijos de la Luz, cuyo capitán general se propone desprestigiarlo para dirigir él mismo la batalla contra la Sombra y sus huestes.Por su parte, las Aes Sedai, tanto las que siguen fieles a la Torre Blanca como las rebeldes, buscan a Rand para ofrecerle su apoyo, aunque éste sospecha que su verdadera intención es usarlo para sus propios fines.Por su calidad literaria, su ambicioso planteamiento y su descomunal historia, La Rueda del Tiempo es la saga de fantasía más importante de los últimos treinta años. El lector que inicie el camino junto a Rand, Mat y Perrin no podrá abandonar el viaje hasta su incierto y sorprendente final.",
    "year": 2020,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 328
  },
  {
    "title": "EL CAMINO DE DAGAS Nº 08/14",
    "isbn": "9788445007075",
    "synopsis": "Sigue la saga de fantasía épica de Robert Jordan, LA RUEDA DEL TIEMPO.Mientras Elayne y Nynaeve, con la ayuda de Detectoras de Vientos y las Allegadas, ponen en funcionamiento el Cuenco de los Vientos, Perrin se encuentra en Ghealdran para conseguir que la reina Alliandre respalde públicamente al Dragón Renacido.Rand continúa en Illian, intentando pacificar el paós, cuando recibe la noticia de que los Shaido están esperando el caos provocado por los Juramentados del Dragón. El tan deseado cambio climático, propiciado por el Cuenco de los Vientos, provoca bruscos cambios de temperatura que dificultan el desplazamiento de tropas.Por ello Rand decide hacer frente a los seanchan en las costas de Illian, con el fin de frenar el avance del ejército invasor. Pero Rand no tendrá que luchar únicamente contra el enemigo.",
    "year": 2020,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 330
  },
  {
    "title": "LA CORONA DE ESPADAS Nº 07/14",
    "isbn": "9788445007068",
    "synopsis": "Elayne, Nynaeve y Aviendha prosiguen con sus investigaciones en Ebou Dar para encontrar el ter''angreal con el que podrían frenar la espantosa ola de calor que azota el mundo. Para ello se reúnen con los Marinos, quienes dan el nombre de Cuenco de los Vientos al objeto. Egwene continúa con su lucha para ser la Sede Amyrlin escogida por las Aes Sedai rebeldes, y acabar con el control que sobre ella ejercen las Asentadas y otros grupos de hermanas.Entre tanto, en los distintos reinos, nobles y dirigentes continúan buscando su propio beneficio, sin tener presente que la mano del Oscuro está tocando el mundo y que la Última Batalla se acerca",
    "year": 2020,
    "authors": [
      "Robert Jordan"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 331
  },
  {
    "title": "FALMUNG Y LA GEMA DE OSCURIDAD",
    "isbn": "9788494677199",
    "synopsis": "\"En una taberna olvidada de la Península de Isgramort, un trovador se dispone a relatar, por primera vez, la auténtica historia de Falmung. La historia real que muy pocos conocen y que hace más de mil años quedó diluida tras los rumores, mitos, relatos y fábulas que poco a poco convirtieron la tenacidad del enano en leyenda.Falmung... Mendigo, guerrero, aventurero, héroe y asesino. Por fin se revelará la verdad sobre su vida y aventuras. Y para ello se debe empezar desde el principio: cuando conoció a su gran amigo Kroyed y los años que pasaron malviviendo como aventureros. Años fugaces durante los que un trabajo en particular les condujo por la senda que les convirtió en los personajes legendarios que conocemos hoy.La auténtica historia jamás contada de Falmung comienza aquí.\"",
    "year": 2018,
    "authors": [
      "Jose Luis Martinez Martinez"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1216
  },
  {
    "title": "AL PIE DE LA MURALLA",
    "isbn": "9781719571739",
    "synopsis": "Fui arrancado con saña de la inocencia de la niñez. Los banelatus robaron mis juegos infantiles y aniquilaron a mis parientes y amigos, obligándome a presenciar su exterminio. Decidieron robarme mi vida para jugar con ella. Me crie entre seres sin sentimientos que, aunque de aspecto semejante al nuestro, carecen de alma y, simplemente, buscan el modo de aniquilar a una raza que creen inferior. Lo hacen a base de herirnos una y otra vez con el fuego de sus mentes. Crecí en Bankada, la ciudad más importante del supremio banelatu del oeste y juro que cada día allí fue una batalla continua en la que todos queríamos morir. Pero ellos se empeñaban en sanarnos una y otra vez para volver a intentar matarnos al día siguiente. Hasta que una vez lo consiguieron, me mataron. Ahora me buscan porque creen que soy el único que conoce el arma que puede acabar con ellos. Y yo solo aspiro a vivir mi vida de fantasma lejos de su muralla.",
    "year": 2018,
    "authors": [
      "Begoña Pro Uriarte"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1226
  },
  {
    "title": "LA CAJA AZUL",
    "isbn": "9788490309926",
    "synopsis": "Hay tres cosas en la vida que merecen ser celebradas: la Palabra, el Silencio y el Amor. A su vez, también merece celebrarse todo lo que es abrazado por ellas. Por esta certeza vengo a este espacio de chamuyo a congratularme y engalanarme con ustedes y con el fragor delicado del tango y el de su envolvente, inmanente, maravilloso e inigualable espectáculo de belleza.Como ya saben, el chamuyo es una voz Lunfarda (proveniente del Caló Chamullar ) que significa algo tan entrañablemente acogedor e irrepetible como es siempre- la conversación íntima. Y es a giro de sus pasos, al deleite de sus quebrados ritmos, al amor dialéctico de su intimidad humana, donde, a modo de Symposium griego y en la cadencia de una danza ritual, he lanzado al vuelo reflexiones en torno a la soledad, al amor, el placer, a la libertad, al poder?",
    "year": 2013,
    "authors": [
      "Ignacio Ochoa"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1254
  },
  {
    "title": "HECATE",
    "isbn": "9788494156366",
    "synopsis": "Sueños de mundos paralelos que se tocan, se entrelazan, se aniquilan. ¿Qué es la locura? ¿Un estado de la mente incapaz de concebir la realidad como la ve la mayoría de los mortales? ¿O la capacidad de ver más allá de lo evidente, de intuir otra dimensión de las cosas? ¿Qué es lo real y qué lo onírico? ¿Somos títeres de esa gran fuerza primigenia creadora del universo? ¿Llegaron hasta nosotros los dioses a través de una puerta cósmica entre dos dimensiones, de una manera que sólo la física cuántica puede atreverse a explicar? ¿Acaso existimos? ¿O creemos que existimos... y por eso somos? Sólo Víctor, un tipo al que una infancia marcada por la tragedia y un latente trastorno neurológico han dotado de una especial sensibilidad, se verá obligado a encontrar respuestas a estas interrogantes cuando una concatenación de extraños sucesos lo arrastren hasta el mismo límite de la locura, donde los sueños y lo empírico visten la misma piel.",
    "year": 2013,
    "authors": [
      "Mario Peloche Hernandez"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1257
  },
  {
    "title": "EL AULLIDO DEL HOMBRE LOBO",
    "isbn": "9788492826544",
    "synopsis": "Lupravia es una tierra maldita, un frío lugar con las montañas cubiertas de nieve, oscuros bosques y páramos envueltos en niebla. Sólo los más temerarios se atreven a entrar en esos parajes plagados de depredadores. Será aquí donde el ataque de un gigantesco lobo te pondrá a prueba frente a un destino incierto. Con el peligro de sucumbir ante el poder de la bestia que llevas dentro, tendrás que encontrar una cura antes de la próxima luna llena. ¿Pero cuánto tiempo serás capaz de sobrevivir en una tierra donde todos le tienen miedo al aullido del hombre lobo?Mitad historia, mitad juego, éste es un libro con una diferencia, una que hará que te conviertas en el héroe. Un lápiz y una goma es todo lo que necesitas para emprender este viaje en el que tendrás que decidir qué camino tomar, contra qué criaturas luchar o a qué peligros les haces frente.",
    "year": 2014,
    "authors": [
      "Steve Jackson"
    ],
    "categories": [
      "Narrativa fantástica"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1261
  },
  {
    "title": "ESCUADRON CIELO: LA COLECCION",
    "isbn": "9788418037757",
    "synopsis": "La colección de novelas cortas de la saga Escuadrón, con ilustraciones exclusivas de los personajes y las escenas eliminadas deEscuadrón con comentarios de Brandon Sanderson.Incluye La defensa del Elíseo.Viajamos con el Escuadrón Cielo a Detritus, el último refugio de la humanidad frente al gobierno hostil de la Supremacía Galáctica. EnEscuadrón, Spensa Nitghshade se convirtió en piloto de caza estelar y pasó a formar parte del Escuadrón Cielo de la Fuerza de Defensa Desafiante con el objetivo de combatir la amenaza de la Supremacía. EnEstelar, se hizo pasar por la alienígena Alanik para infiltrarse en una estación espacial de la Supremacía y robar sus hipermotores.",
    "year": 2022,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 8
  },
  {
    "title": "MONA LISA ACELERADA Nº 03/03 TRILOGIA DE SPRAWL",
    "isbn": "9788445009420",
    "synopsis": "El fantasma fue el regalo de despedida de su padre. Se lo entregó un secretario vestido de negro en la zona de embarque del aeropuerto de Narita. Mona es una joven con un pasado turbio y un futuro incierto cuya vida da un vuelco cuando su proxeneta la vende a un cirujano plástico de Nueva York y, de la noche a la mañana, se convierte en otra persona. Angie Mitchell es una estrella famosa de Senso/Red de Hollywood con un talento muy particular, y ha empezado a recordar cosas a pesar de que los jefes de su estudio se esfuerzan para que no se dé cuenta. No tardará en descubrir quién es en realidad? y por qué no necesita una consola para enchufarse en el ciberespacio. Todo se pone en marcha en el interior de la matriz, y los seres humanos empiezan a usarse como piezas en un tablero.",
    "year": 2022,
    "authors": [
      "William Gibson"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 11
  },
  {
    "title": "EXHALACION",
    "isbn": "9788417517793",
    "synopsis": "¿Qué pasaría si un inocente juguete dinamitara nuestra noción de libre albedrío? ¿Y si fuera posible ponerse en contacto con versiones de nosotros mismos en otras líneas temporales? No importa cuál sea el tema que trate Ted Chiang en sus narraciones, siempre demuestra una formidable habilidad para indagar en los enigmas de la condición humana y abordar los conflictos éticos que la relación con la tecnología plantea en nuestra existencia, desde una perspectiva abiertamente positiva y vitalista. Reveladores, elegantes y sorprendentes, los relatos de Exhalación sitúan a Ted Chiang entre los autores indiscutibles de la literatura estadounidense actual.",
    "year": 2020,
    "authors": [
      "Ted Chiang"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 19
  },
  {
    "title": "SINSONTE",
    "isbn": "9788418668371",
    "synopsis": "Con ecos deFahrenheit 451, Un mundo feliz oBlade Runner, Sinsonte es una de las novelas de ciencia ficción más míticas de nuestro tiempo, que se lee como una elegía a los olvidados y un viaje de autodescubrimiento.Han pasado cientos de años y la Tierra se ha convertido en un planeta sombrío y distópico en el que los robots trabajan y al ser humano solo le queda languidecer, arrullado por la dicha electrónica y la felicidad narcótica. En semejante mundo sin arte, sin lectura y sin niños, la gente opta por quemarse viva para no soportar la realidad. Y es en este escenario donde Spofforth, la máquina más perfecta jamás creada, un androide de duración ilimitada que ha vivido siglos y que en la actualidad es decano de la Universidad de Nueva York, acaricia su máximo anhelo: poder morir. El único problema está en que su programación le impide suicidarse.",
    "year": 2022,
    "authors": [
      "Walter Tevis"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 21
  },
  {
    "title": "STAR WARS EL LIBRO DE LOS SITH",
    "isbn": "9788445005798",
    "synopsis": "Desata el poder del lado oscuro con El libro de los Sith.Los Sith han existido desde tiempo inmemorial. Cuando los señores Sith comenzaron a ganar poder, unos pocos recogieron sus planes y su filosofía para hacerse con el control de la galaxia. Después este conocimiento desapareció. O al menos eso parecía…Sus escritos fueron conservados por reconocidos Sith, e incluso por algunos Jedi, quienes añadieron sus reflexiones. Darth Sidious rastreó lo que quedaba de los cinco textos más legendarios y a partir de ellos, escribió un sexto, su propio manifiesto. Todos estos documentos reunidos conforman El libro de los Sith",
    "year": 2021,
    "authors": [
      "Daniel Wallace"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 31
  },
  {
    "title": "LA HISTORIA DE TU VIDA",
    "isbn": "9788498891355",
    "synopsis": "Una torre que se alza sobre la llanura mesopotámica hasta tocar la bóveda del cielo. Dos hombres que alcanzan un grado de inteligencia tan alto que se asemejan a dioses. La prueba de que las matemáticas carecen de sentido. Un lenguaje alienígena que permite a quienes lo leen expandir su consciencia a lo largo del tiempo. La cábala y la teoría de la preformación se combinan en una Inglaterra victoriana salida de nuestros sueños, o de nuestras pesadillas. Ante la llegada de los metahumanos, la ciencia humana se ve reducida a una nota a pie de página. En un universo donde Dios existe sin que quepa ninguna duda, ¿es posible no amarle? Y si pudieras programarte para ignorar las apariencias, ¿te arriesgarías a perder toda percepción de la belleza humana?Ted Chiang, galardonado con el premio John W. Campbell Jr., brilla como una nova en el firmamento de la ciencia-ficción.",
    "year": 2021,
    "authors": [
      "Ted Chiang"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 32
  },
  {
    "title": "BINTI: HOGAR",
    "isbn": "9788494795848",
    "synopsis": "\"Binti: Hogar es la segunda parte de esta emocionante trilogía. Binti y Okwu llevan un año en la Universidad Oomza. Un año desde que Binti consiguiera la unión entre civilizaciones en guerra y desde que encontrara amistad en el lugar más inesperado.En esta ocasión, Binti tendrá que volver a casa con Okwu y enfrentarse a su familia y comunidad, además de hacer posible que, por primera vez en más de cien años, una medusa ponga pie en la Tierra para un fin que no sea la guerra.\"",
    "year": 2018,
    "authors": [
      "Nnedi Okorafor"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 34
  },
  {
    "title": "STAR WARS LAS GUERRAS DE LOS CAZARRECOMPENSAS Nº 2/3 NAVE ESCLAVA (NOVELA)",
    "isbn": "9788411121477",
    "synopsis": "El antaño poderoso Gremio de Cazarrecompensas está escindido en facciones enfrentadas. Ahora, la enorme recompensa ofrecida por un soldado de asalto imperial renegado está a punto de desatar un frenesí de codicia homicida. Intentando alimentar los rumores sobre su muerte, Boba Fett abandona su nave, la Esclavo I, decidido a cobrar esa recompensa. Sin embargo, cada movimiento que hace lo acerca a la trampa tendida por el astuto Príncipe Xizor. Fett preferiría morir a convertirse en un peón de Xizor en la guerra del Emperador contra los rebeldes. Y quizá deba hacerlo porque, si quiere ser libre, deberá ser más hábil que un arma viviente que se alimenta de espíritus humanos. Después, deberá sortear una galaxia repleta de enemigos letales deseosos de hacer realidad los rumores sobre su muerte. Es temido y admirado, respetado y odiado. Boba Fett es el cazarrecompensas más exitoso de la galaxia.",
    "year": 2022,
    "authors": [
      "K. W. Jeter"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 36
  },
  {
    "title": "WEIRD TALES 1933-1942",
    "isbn": "9788492492039",
    "synopsis": "Más Weird Tales, por Francisco Arellano WEIRD TALES El juez supremo ,por J. Paul Suter La diosa de zafiro, por Nictzin Dyalhis El vengador de la Atlántida, por Edmond Hamilton El regreso de Sarah, por August Derleth Las semillas del espacio, por Edmond Hamilton La Tigresa, por David H. Keller La casa del éxtasis, por Ralph Milne Farley Esclavo de las llamas, por Robert Bloch Mami, por Mary Elizabeth Counselman Hydra, por Henry Kuttner",
    "year": 2008,
    "authors": [
      "Francisco Arellano"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 41
  },
  {
    "title": "STAR WARS THE HIGH REPUBLIC LUZ DE LOS JEDI (NOVELA)",
    "isbn": "9788413416366",
    "synopsis": "Empieza la nueva etapa en el Universo Star Wars con esta novela.Mucho antes de la Primera Orden, antes del Imperio, incluso antes de La Amenaza Fantasma, existió la edad de oro. Dos siglos antes de la saga Skywalker.Vivimos una época dorada. Intrépidos exploradores hiperespaciales expanden los límites de la República hasta las estrellas más remotas, los mundos prosperan bajo el benévolo liderato del Senado y reina la paz en la galaxia, defendida por la sabiduría y fuerza de la célebre orden de usuarios de la Fuerza conocidos como Jedi. Con los Jedi en la cima de su poder, los ciudadanos libres de la galaxia confían en su habilidad para capear cualquier temporal. Pero incluso la luz más brillante proyecta alguna sombra y algunos temporales desafían cualquier preparación.Cuando una impactante catástrofe en el hiperespacio hace pedazos una nave, la lluvia de metralla que emerge del desastre amenaza a todo un sistema.",
    "year": 2021,
    "authors": [
      "Charles Soule"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 54
  },
  {
    "title": "STAR WARS DARTH BANE CAMINO DE DESTRUCCION",
    "isbn": "9788491739050",
    "synopsis": "Inicio de la trilogía de Darth Bane (Camino de destrucción, Regla de dos y Dinastía del mal).Huyendo de las vengativas fuerzas republicanas, Dessel, un minero de cortosis, se enrola en las filas del ejército Sith, uniéndose a la sangrienta guerra contra la República y sus héroes Jedi. Allí, su brutalidad, astucia y excepcional dominio de la Fuerza le convierten rápidamente en un guerrero de renombre. Pero sus jefes, siempre vigilantes, creen que le aguarda un futuro mucho más brillante. Como acólito de la academia Sith, donde estudia los secretos y poderes del lado oscuro, Dessel adopta su nueva identidad: Bane. Pero la verdadera prueba aún está por llegar. Para poder ser aceptado en la Hermandad de la Oscuridad, deberá desafiar las tradiciones más secretas y rechazar todo lo que le han enseñado.",
    "year": 2019,
    "authors": [
      "Drew Karpyshyn"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 59
  },
  {
    "title": "PROYECTO HAIL MARY",
    "isbn": "9788418037016",
    "synopsis": "La nueva novela del autor deEl marciano, que se convertirá en una película protagonizada y producida por Ryan Gosling.UN ÚNICO ASTRONAUTA.UNA MISIÓN IMPOSIBLE.UN ALIADO QUE JAMÁS HABRÍA IMAGINADO.Ryland Grace es el único superviviente en una misión desesperada. Es la última oportunidad y, si fracasa, la humanidad y la Tierra misma perecerán.Claro que, de momento, él no lo sabe. Ni siquiera puede recordar su propio nombre, y mucho menos la naturaleza de su misión o cómo llevarla a cabo.Lo único que sabe es que ha estado en coma inducido durante mucho mucho tiempo. Acaba de despertar y se encuentra a millones de kilómetros de su hogar, sin más compañía que la de dos cadáveres.Muertos sus compañeros de tripulación, y a medida que va recuperando confusamente los recuerdos, Grace se da cuenta de que se enfrenta a una misión imposible.",
    "year": 2021,
    "authors": [
      "Andy Weir"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 60
  },
  {
    "title": "EL MINISTERIO DEL FUTURO",
    "isbn": "9788445009833",
    "synopsis": "Una extraordinaria visión de cómo será el cambio climático.El Ministerio del Futuroes una obra maestra de la imaginación. Narra a través de testimonios ficticios cómo nos afectará a todos el cambio climático. Su visión no es la de un mundo desolado y apocalíptico, sino la de un futuro que ya se nos echa encima…y cuyos desafíos tal vez consigamos superar por los pelos.Es una novela actual e impactante, descorazonadora y esperanzadora a partes iguales, y es uno de los libros más poderosos y originales que jamás se hayan escrito sobre el cambio climático.Creado en el año 2025, el objetivo del nuevo organismo era sencillo: Defender a las futuras generaciones de la humanidad y proteger a todos los seres vivos, del presente y del futuro.",
    "year": 2021,
    "authors": [
      "Kim Stanley Robinson"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 62
  },
  {
    "title": "LA ESTIRPE DE LILITH (TRILOGIA XENOGENESIS)",
    "isbn": "9788418037108",
    "synopsis": "La trilogía olvidada de la gran dama de la ciencia ficción.Treinta años después de su primera publicación en castellano,La estirpe de Lilith, título que reúne la Trilogía Xenogénesis en un solo volumen, vuelve a las librerías dispuesta a reivindicar a Octavia E. Butler como la gran pionera que deslumbró en ciencia ficción siendo una mujer negra. Hoy se la considera la primera escritora afroamericana de género en incorporarse al canon de la literatura norteamericana.Lilith Iyapo despierta en una nave espacial oankali, la raza alienígena que salvó a la humanidad de la extinción después de que la Tierra quedase devastada a causa de una guerra nuclear. Estos seres han mantenido a Lilith y a otros supervivientes dormidos en animación suspendida durante siglos.",
    "year": 2021,
    "authors": [
      "Octavia E. Butler"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 63
  },
  {
    "title": "LAS LUMINOSAS",
    "isbn": "9788491878346",
    "synopsis": "Chicago, 1931. Harper Curtis, un vagabundo violento, se topa con una casa que oculta un sorprendente secreto: es la puerta que lo traslada a otros momentos del tiempo para acechar a mujeres jóvenes que se le aparecen como \"luminosas\", rodeadas de una aureola especial que las convierte en el preciado objeto de sus instintos asesinos. Chicago, 1992. La vida de Kirby Mazrachi se ha trastocado tras el brutal intento de asesinarla. Mientras lucha por encontrar a su atacante, su único aliado es Dan, un antiguo periodista de homicidios que se ocupó del caso y que trata de protegerla de su obsesión. A medida que Kirby avanza en la investigación descubre a otras chicas, las que no lo lograron. Las pruebas de los crímenes son imposibles y la respuesta parece ocultarse en una casa abandonada en medio de la ciudad.",
    "year": 2022,
    "authors": [
      "Lauren Beukes"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 67
  },
  {
    "title": "QUIENES SE MARCHAN DE OMELAS",
    "isbn": "9788418930478",
    "synopsis": "Con descripciones deliberadamente vagas y vívidas, el narrador describe un festival de mediados de verano en la ciudad utópica de Omelas, cuya prosperidad depende de la miseria perpetua de un chico. Quienes se marchan de Omelas fue nominado al Premio Locus al mejor relato corto en 1974​ y ganó el Premio Hugo al mejor relato corto en el mismo año.«Ursula K. Le Guin es más que una escritora de fantasía para adultos y ciencia ficción [ ] ella es una filósofa; una exploradora de los paisajes de la mente».Cincinnati Enquirer",
    "year": 2022,
    "authors": [
      "Ursula K. Le Guin"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 81
  },
  {
    "title": "ESCUADRON",
    "isbn": "9788417347277",
    "synopsis": "El inicio de la nueva trilogía young adult de Sanderson: Top Gun en el espacio. El mundo lleva siglos en guerra; la humanidad está atrapada en un planeta constantemente atacado por unos alienígenas decididos a destruirla. Los pilotos son los ºnicos heroes dispuestos a combatir el enemigo. Spensa es una joven que siempre ha soñado convertirse en piloto y defender a la Tierra. Pero su destino se cruza con el de su padre, un piloto que fue asesinado tras abandonar a su equipo, anulando sus opciones de asistir a la escuela de vuelo. De pronto, el ataque alienígena ha hecho duplicar la flota aerea de los humanos, facilitando que Spensa ahora sí pueda volar al espacio... La crítica ha dicho: \"Un escritor brillante.\" Patrick Rothfuss",
    "year": 2018,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 90
  },
  {
    "title": "EL PROBLEMA DE LOS TRES CUERPOS (TRILOGIA DE LOS TRES CUERPOS 1)",
    "isbn": "9788466659734",
    "synopsis": "El primer libro de la «Trilogía de los Tres Cuerpos», el fenómeno editorial chino que ha conquistado al mundo y ha ganado el premio Hugo 2015 a la mejor novela.El problema de los tres cuerpos es la primera novela no escrita originariamente en inglés galardonada con el premio Hugo, el Nobel del género de la ciencia ficción.Su autor, Cixin Liu, ha sido considerado el gran descubrimiento del género y es capaz de vender cuatro millones de ejemplares solamente en China y de hacerse con prescriptores de la talla deBarack Obama, quien seleccionó El problema de los tres cuerpos como una de sus lecturas navideñas de 2015, yMark Zuckerberg, que lo convirtió en la primera novela de su club de lectura.El público y la crítica de los cinco continentes se rinden ante esta obra maestra, enormemente visionaria, sobre el papel de la ciencia en nuestras sociedades, que nos ayuda a comprender el pasado y el futuro de China, pero también, leída en clave geo",
    "year": 2016,
    "authors": [
      "Cixin Liu"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 97
  },
  {
    "title": "THE HORUS HERESY Nº 51/54 ESCLAVOS DE LA OSCURIDAD",
    "isbn": "9788445008393",
    "synopsis": "Una fantástica novela Warhammer.Tras un largo y arduo conflicto, los traidores al fin se aproximan a Terra. Sin embargo, pronto perderán la oportunidad para atacar: tanto Guilliman como el León regresan a toda prisa, y sus ejércitos podrían girar las tornas de la batalla. Las tropas del Señor de la guerra deben reunirse, pues solo entonces podrán asaltar el mundo del Trono.Mientras Mortarion se adelanta para actuar como la vanguardia de la flota, recae sobre Lorgar y Perturabo la tarea de reunir a Fulgrim y a Angron, quienes ya han sido enaltecidos como demonios y tal vez se encuentren más allá del alcance de la voluntad del Señor de la guerra. No obstante, Horus está malherido, y, mientras la batalla más grande de la galaxia se cierne sobre Terra, es Maloghurst quien debe asegurarse de que su fracturada Legión se mantenga unida y de rescatar al propio Horus del borde del abismo.",
    "year": 2022,
    "authors": [
      "John French"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 107
  },
  {
    "title": "FLORES PARA ALGERNON",
    "isbn": "9788498891157",
    "synopsis": "\"Charlie Gordon está a punto de iniciar un viaje sin precedentes. Nacido con un cociente intelectual anormalmente bajo, lo han elegido como perfecto sujeto de pruebas para una cirugía experimental que, de funcionar, aumentará su inteligencia. El método ya ha dado un resultado espectacular al ser aplicado a un ratón de laboratorio llamado Algernon. Según hace efecto el tratamiento, la inteligencia de Charlie se expande hasta sobrepasar la de los propios doctores que produjeron su metamorfosis. El experimento parece ser un logro científico de primer orden, hasta que Algernon comienza a sufrir inesperadas consecuencias. ¿Le pasará lo mismo a Charlie? Daniel Keyes obtuvo el prestigioso premio Nebula con esta novela, que en su versión corta recibió también el popular premio Hugo, y que fue llevada al cine como Charly. Flores para Algernon es un clásico de la ciencia-ficción, y uno de los libros más vendidos de la historia del género. \"",
    "year": 2019,
    "authors": [
      "Daniel Keyes"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 114
  },
  {
    "title": "BINTI: LA MASCARADA NOCTURNA",
    "isbn": "9788412059915",
    "synopsis": "En La Mascarada Nocturna se da una búsqueda donde la comunicación puede ser la esperanza, y de la que Binti saldrá inevitablemente transformada. La tradición, la identidad, la pertenencia: todo está en cuestión en el universo que la imaginación de Nnedi Okorafor nos regala. Un mundo que, por inabarcable, complejo y rebosante de vida diversa, podemos ver reflejado en el nuestro.¿Logrará encontrar nuestra heroína su lugar y su función en la galaxia?La Mascarada Nocturna es la tercera y última parte de la trilogía Binti.",
    "year": 2019,
    "authors": [
      "Nnedi Okorafor"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 127
  },
  {
    "title": "LAS CRISALIDAS",
    "isbn": "9788491817345",
    "synopsis": "BENDITA SEA LA NORMA.EN LA PUREZA ESTÁ NUESTRA SALVACIÓN.¡CUIDADO CON LOS MUTANTES!Después de la Tribulación, una catástrofe apocalíptica que da lugar a mutaciones genéticas, las desviaciones de la norma son consideradas Blasfemias. Los animales y plantas que no tengan un aspecto normal son eliminados, y los humanos son expulsados a los Márgenes.Nadie sospecha en su aldea que David y Rosalind también son mutantes, pero a medida que se hacen mayores cada vez les resulta más difícil ocultar su propia aberración y se ven obligados a huir a las Malas Tierras para no ser descubiertos.",
    "year": 2019,
    "authors": [
      "John Wyndham"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 128
  },
  {
    "title": "EL RELATO",
    "isbn": "9788445009772",
    "synopsis": "La terrícola Sutty vive de forma solitaria en Dovza, la capital del planeta Aka. El planeta vive bajo el férreo control de un gobierno capitalista, la Corporación, que insiste en convertir a todos los ciudadanos en puros productores-consumidores. Para ello procede a destruir sistemáticamente todo vestigio de cualquiera de las formas tradicionales de vida. Aunque el mundo ficticio de El relato y sus peculiares costumbres no tienen relación alguna con la China antigua o moderna, tanto esa sociedad como la «Tierra futura» de la que proviene su heroína, reflejan ciertas tendencias y pasiones políticas y religiosas de nuestra propia Tierra en el cambio de milenio. Los gobiernos totalitarios y las religiones fundamentalistas operan con el mismo objetivo, reemplazando la búsqueda de la verdad por una respuesta incuestionable y castigando a los que cuestionan. El Futuro, en la ficción, no suele ser más que un modo de mirar el Presente.",
    "year": 2021,
    "authors": [
      "Ursula K. Le Guin"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 133
  },
  {
    "title": "STAR WARS THE OLD REPUBLIC REVAN",
    "isbn": "9788491739074",
    "synopsis": "Una novela Star Wars sobre un Jedi oscuro.Revan: héroe, traidor, conquistador, villano, salvador. Un Jedi que salió de Coruscant para derrotar a los mandalorianos y regresó convertido en un discípulo del lado oscuro y decidido a destruir la República. El Consejo Jedi le devolvió la vida, pero Revan pagó un precio muy alto por su redención: borraron sus recuerdos. Solo le quedan las pesadillas... y un miedo atroz y duradero.¿Qué sucedió exactamente más allá del Borde Exterior? Revan no lo recuerda, pero tampoco puede olvidarlo del todo. Descubrió un terrible secreto que amenaza la existencia de la República. No sabe qué es, ni cómo detenerlo, pero es muy probable que fracase en el intento, pues nunca se ha enfrentado a un enemigo tan diabólico y poderoso. Pero solo la muerte le impediría intentarlo…",
    "year": 2021,
    "authors": [
      "Drew Karpyshyn"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 141
  },
  {
    "title": "UN CHICO Y SU PERRO EN EL FIN DEL MUNDO",
    "isbn": "9788445008317",
    "synopsis": "Me llamo Gris. No he ido nunca a la escuela. Jamás he tenido amigos y en toda mi vida no he conocido suficientes personas como para jugar un partido de fútbol. Mis padres me han contado que antes el mundo estaba lleno de gente, antes de que se vaciara. Pero nunca nos hemos sentido solos en nuestra isla. Nos tenemos los unos a los otros, y tenemos a nuestros perros. Entonces llegó el ladrón. Novela elegida como una de las mejores historias de ciencia ficción de 2019 según Kirkus Reviews. Una historia con el estilo de La carretera pero con un toque esperanzador. «Un relato evocador, lleno de suspense que culmina en un asombroso giro argumental.» ?Entertainment Weekly «Un chico y su perro en el fin del mundo es una historia de supervivencia, coraje y esperanza ambientada en las ruinas de nuestro mundo.",
    "year": 2020,
    "authors": [
      "C. A. Fletcher"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 154
  },
  {
    "title": "STAR WARS THRAWN ALIANZAS (NOVELA)",
    "isbn": "9788413411781",
    "synopsis": "Segunda novela de la nueva trilogía de Thrawn. Novela canónica escrita por el autor best seller the Star Wars, Timothy Zahn.\"He sentido una perturbación en la Fuerza\". Palabras ominosas en cualquier circunstancia, pero más aún cuando las pronuncia el emperador Palpatine. En Batuu, en los límites de las Regiones Desconocidas , una amenaza para el Imperio está arraigando: su existencia es poco más que un destello, sus consecuencias aún no se conocen.Pero es lo suficientemente inquietante para el líder imperial como para justificar la investigación de sus agentes más poderosos: el implacable Lord Darth Vader y el brillante estratega Gran Almirante Thrawn. Rivales feroces por el favor del emperador y adversarios francos en los asuntos imperiales, incluido el proyecto Estrella de la Muerte.",
    "year": 2020,
    "authors": [
      "Timothy Zahn"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 158
  },
  {
    "title": "STAR WARS LA ULTIMA ORDEN (NOVELA)",
    "isbn": "9788491468899",
    "synopsis": "La última orden cierra la trilogía de Thrawn, uno de los villanos más temidos del universo Star Wars.La República asediada se tambalea tras los ataques del Gran Almirante Thrawn, que ha reunido los restos del ejército imperial y ha repelido a los rebeldes con una tecnología abominable recuperada de la fortaleza secreta del Emperador: los soldados clon. Mientras Thrawn prepara su asedio final, Han y Chewbacca intentan formar una coalición de contrabandistas para lanzar un ataque desesperado contra el Imperio. Mientras tanto, Leia mantiene unida la Alianza y se prepara para el nacimiento de sus gemelos: dos nuevos Jedi. La República, abrumada por las naves y los clones liderados por Thrawn, tiene una última oportunidad... enviar un pequeño ejército liderado por Luke Skywalker a la fortaleza que alberga las terribles máquinas de clonación de Thrawn.",
    "year": 2018,
    "authors": [
      "Timothy Zahn"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 160
  },
  {
    "title": "LA SANTA",
    "isbn": "9788445005507",
    "synopsis": "En la sangrienta cruzada por los mundos de Sabbat, los guerreros del imperio se enfrentan a las fuerzas del Caos. En primera línea de este conflicto se encuentra la Guardia Imperial, un número ingente de soldados que luchan por preservar el reino sagrado del Emperador. Ibram Gaunt y los hombres del Primero y Único de Tanith están en lo más reñido de la batalla. Obligados a huir de su planeta antes de que fuese destruido por el Caos, su condición de exploradores especializados les ha granjeado el apodo de \"Fantasmas\", al tiempo que todas las misiones peligrosas que sus comandantes esten dispuestos a asignarles. Sigue las aventuras epicas de Gaunt y sus hombres tal y como ellos lo harían, al grito de: Hombres de Tanith, ¿quereis vivir eternamente?",
    "year": 2018,
    "authors": [
      "Dan Abnett"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 161
  },
  {
    "title": "LA PUERTA DE ABADON (THE EXPANSE 3)",
    "isbn": "9788417347208",
    "synopsis": "La tercera parte de «The Expanse», la saga superventas deThe New York Timesen que se basa la exitosa serie de televisión homónima producida por Syfy y emitida en Netflix.«Hacía tiempo que no leía unaspace opera tan buena.»George R.R. MartinDurante generaciones, el Sistema Solar (Marte, la Luna y el cinturón de asteroides) ha conformado la gran frontera de la humanidad. Hasta ahora. El artefacto alienígena que realizaba su obra bajo las nubes de Venus ha aparecido en la órbita de Urano, donde ha construido una puerta enorme que se abre hacia un espacio sin estrellas.Jim Holden y la tripulación de la Rocinante forman parte de una gran flotilla de naves militares y científicas que parten para examinar el artefacto. Pero, entre bambalinas, se empieza a desarrollar una trama intrincada que tiene como finalidad la destrucción de Holden.",
    "year": 2018,
    "authors": [
      "James S. A. Corey"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 163
  },
  {
    "title": "EL ZOO DE PAPEL Y OTROS RELATOS",
    "isbn": "9788491046875",
    "synopsis": "Quince relatos y novelas cortas de uno de los mejores escritores de ficción breve de la ciencia-ficción.\"El zoo de papel\" es la primera obra que ha obtenido los tres grandes premios del género en el mismo año.\"La obra breve de Ken Liu ha ganado todos los premios internacionales de prestigio y, lo que es más importante, ha conquistado también y para siempre el corazón de los lectores de todo el mundo.\"Mariano Villarreal, Literatura Fantástica\"A través de todos estos cuentos, Liu utiliza tropos de la fantasía y la ciencia ficción para explorar de forma profunda, inteligente y, en muchas ocasiones, tremendamente emotiva una gran diversidad de temas con la intención final de arrojar un poco de luz sobre la gran pregunta de qué significa ser humano...",
    "year": 2017,
    "authors": [
      "Ken Liu"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 168
  },
  {
    "title": "LA GUERRA DE CALIBAN (THE EXPANSE 2)",
    "isbn": "9788466660884",
    "synopsis": "La continuación de El despertar del Leviatán, la saga superventas del New York Times en que se basa la exitosa serie de TV The Expanse, producida por Syfy y emitida por Netflix. En Ganímedes, asolada por la guerra y fuente de recursos de los planetas exteriores, una marine de Marte asiste a la aniquilación de su pelotón a manos de un supersoldado monstruoso. En la Tierra, una política de alto rango hace todo lo posible por evitar que vuelva a estallar una guerra interplanetaria. Y en Venus, una protomolécula alienígena se ha hecho con el planeta y desencadenado una serie de cambios misteriosos que amenazan con extenderse por el Sistema Solar. El futuro de la humanidad depende de que una sola nave evite una invasión alienígena. Detrás del seudónimo James S. A. Corey se esconden el autor de ciencia ficción y fantasía Daniel Abrahan y Ty Franck, asistente personal de George R. R.",
    "year": 2017,
    "authors": [
      "James S. A. Corey"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 169
  },
  {
    "title": "MATERIA OSCURA",
    "isbn": "9788416858217",
    "synopsis": "CUALQUIER DECISIÓN SE RAMIFICA EN UN NUEVO MUNDO. Jason Dessen vive en Chicago, donde ha renunciado a sus grandes aspiraciones científicas para dar clases y centrarse en su familia. Una noche, tras asistir a la celebración en honor de un antiguo compañero galardonado con un importante premio de astrofísica, Jason se dirige a casa y nunca llega. Un hombre oculto tras una máscara de geisha lo conduce a punta de pistola a una central eléctrica abandonada, donde le inyecta algo.Cuando recobra la conciencia, unos desconocidos con trajes especiales lo reciben con las palabras «bienvenido de nuevo». Pero esta realidad no es la que conoce: su mujer no es la misma, su hijo no ha nacido y él ni siquiera es profesor. ¿Es este mundo un sueño? ¿O acaso lo era su vida anterior?«Excepcional (.). Una aventura apasionante con una trama ingeniosa sobre el amor, el arrepentimiento y la superposición cuántica.",
    "year": 2017,
    "authors": [
      "Blake Crouch"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 171
  },
  {
    "title": "THE HORUS HERESY Nº 53/54 MUERTE TITANICA",
    "isbn": "9788445008416",
    "synopsis": "La armada de Horus se reúne. Ya ha derrotado a todos los enemigos que se interponían en su camino, incluso al propio verdugo del Emperador. Lo único que queda es una barrera antes de que pueda dirigirse a Terra para arrasar con el sueño del Emperador. El sistema Beta-Garmon ocupa la única ruta viable, la más directa, hacia el sistema solar y Terra. Para derribar aquella barrera, Horus congrega a una hueste de guerra de unas proporciones inimaginables y a un número incontable de titanes. Perder en Beta-Garmon significa perder la guerra, y Horus no tiene ninguna intención de volver atrás. Sin embargo, el Imperio también comprende la importancia de Beta-Garmon y despliega un ejército colosal, conformado por unas cohortes del ejército de números casi infinitos y un conjunto de titanes capaz de desafiar incluso al poderío marcial del Señor de la Guerra.",
    "year": 2022,
    "authors": [
      "Guy Haley"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 172
  },
  {
    "title": "CIAPHAS CAIN OMNIBUS",
    "isbn": "9788445012383",
    "synopsis": "En el futuro devastado por la guerra del cuadragésimo primer milenio, el comisario Ciaphas Cain, héroe del Imperio, es respetado por sus compañeros y una inspiración para sus hombres, al menos eso es lo que la propaganda quiere hacerte creer. La realidad es muy diferente, ya que Ciaphas simplemente busca una vida fácil y una manera de mantenerse fuera de peligro. Sin embargo, el destino tiene la costumbre de arrojarlo a las situaciones más mortales, y la suerte siempre se las arregla para llevarlo hacia el más alto de los pedestales. Para sobrevivir, el comisario Cain debe esquivar, fanfarronear y engañar para salir de los problemas, ¡incluso si aumenta su estatus más allá de su control!",
    "year": 2022,
    "authors": [
      "Sandy Mitchell"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 178
  },
  {
    "title": "ANSIBLES, PERFILADORES Y OTRAS MAQUINAS DE INGENIO",
    "isbn": "9788412520521",
    "synopsis": "Esta colección de diez cuentos se inscribe en el genero de la ciencia ficción. Las historias giran en torno a los cambios que las relaciones humanas sufrirán a raíz de los avances tecnológicos. Casi todos los cuentos están ubicados en la Ciudad de Mexico, o una versión de ella proyectada hacia distintos futuros, algunos apocalípticos y algunos ultratecnologizados, aunque una de las historias sucede en el espacio. Las protagonistas son mujeres que se encuentran en una disyuntiva en sus relaciones personales a partir de un dispositivo de tecnología mental o de asimilación de la realidad que, a pesar de que debería facilitar la vida, amenaza con volver más asfixiantes, impredecibles o peligrosas las interacciones humanas. La mente y sus secretos, la percepción y la duda de si percibimos sólo lo que deseamos, los límites de la intimidad; estos son algunos de los temas que trata el libro.",
    "year": 2022,
    "authors": [
      "Andrea Chapela"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 179
  },
  {
    "title": "METRO 2033 (CTS: COMIENZA TU SERIE)",
    "isbn": "9788445013700",
    "synopsis": "Año 2033. Tras una guerra nuclear devastadora, amplias zonas del mundo han quedado sepultadas bajo escombros y cenizas debido a la radiación. También Moscú se ha transformado en una ciudad fantasma. Los supervivientes se han refugiado bajo tierra, en la red de metro. En cada una de las estaciones, convertidas en pequeñas ciudades Estado, sus habitantes se agrupan en torno a a las más diversas ideologías, religiones o movidos por un único objetivo: impedir una invasión de las criaturas mutantes del exterior. Artyom, un joven soldado, será el elegido para penetrar en el corazón del metroa hasta la legendaria Polis y alertar a todos del peligo que acecha a la estación de la que procedem la VDNKh, y a toda la red metropolitana. De él dependerá el futuro de su hogar, del Metro y puede que de toda la Humanidad.",
    "year": 2022,
    "authors": [
      "Dmitry Glukhovsky"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 183
  },
  {
    "title": "GITSLAYER",
    "isbn": "9788445011751",
    "synopsis": "Decidido a librarse de la runa de Matafuegos que lleva enterrada en el pecho, Gotrek Gurnisson, el más extraordinario matador que haya existido jamás, se adentra en el extraño y alquímico reino de Chamon. Los señores kharadron de Barak-Urbaz le ofrecen la oportunidad de poner fin a su búsqueda mediante su misteriosa aeterciencia. Pero cuando la Luna Mala sale y el letal Gloomspite Gitz amenaza con destruir el puerto aéreo, Gotrek se enfrenta con el enemigo más antiguo de su pueblo, los pieles verdes. Mientras su compañero de viaje, el elfo Maleneth Hojabruja, supera toda clase de dificultades para mantenerlo vivo, Gotrek se lanza de cabeza a una sangrienta batalla por la supervivencia que lo enviará al corazón húmedo, tenebroso y fungoso del manicomio de Skragrott.",
    "year": 2022,
    "authors": [
      "Darius Hinks"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 184
  },
  {
    "title": "STAR WARS LEYENDAS. KENOBI (NOVELA)",
    "isbn": "9788411121170",
    "synopsis": "Tatooine, un inhóspito planeta desértico en los confines del espacio civilizado, es un lugar extraño para encontrar a un Maestro Jedi oculto. Conocido por los lugareños simplemente como «Ben», el forastero de la barba y la toga no cuenta nada de su pasado, poniendo gran empeño en seguir siendo un extraño. Pero cuando estalla la violencia entre algunos de los granjeros de Tatooine y una tribu de bandidos tusken, Ben acaba involucrándose. Esa maniobra puede revelar que es Obi-Wan Kenobi, héroe de las Guerras Clon y enemigo del Imperio? poniendo en peligro su verdadera misión, proteger a la última esperanza de la galaxia. Pero cuando se producen derramamientos de sangre injustos, los inocentes ven sus vidas amenazadas y se desenmascara a un despiadado oponente, Ben no tiene más remedio que recurrir a su sabiduría Jedi y al formidable poder de la Fuerza.",
    "year": 2022,
    "authors": [
      "John Jackson Miller"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 192
  },
  {
    "title": "SOLARIS",
    "isbn": "9788415130093",
    "synopsis": "Impedimenta se complace en presentar, por primera vez en traducción directa del polaco, Solaris, la mítica novela que consagró a Stanisław Lem como autor de culto. Un texto hoy en día considerado un clásico sin paliativos de la literatura moderna. Kris Kelvin acaba de llegar a Solaris. Su misión es esclarecer los problemas de conducta de los tres tripulantes de la única estación de observación situada en el planeta. Solaris es un lugar peculiar: no existe la tierra firme, únicamente un extenso océano dotado de vida y presumiblemente, de inteligencia. Mientras tanto, se encuentra con la aparición de personas que no deberían estar allí. Tal es el caso de su mujer quien se había suicidado años antes, y que parece no recordar nada de lo sucedido.",
    "year": 2011,
    "authors": [
      "Stanislaw Lem"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 195
  },
  {
    "title": "STAR WARS SKYWALKER: UNA FAMILIA EN GUERRA (NOVELA)",
    "isbn": "9788411121422",
    "synopsis": "A muchos les resulta familiar la leyenda de Luke Skywalker o las historias que se susurran sobre Kylo Ren o Darth Vader, pero esta crónica reúne todas las fuentes disponibles, incluidos los bancos de memoria de R2-D2, los diarios y la correspondencia, las holograbaciones y las noticias, además de documentación sobre acontecimientos galácticos, por lo que cuenta de cabo a rabo la historia de la dinastía de los Skywalker. Además, esta narración explora en profundidad los complejos motivos y los estados psicológicos de los diferentes miembros de la familia a medida que se enfrentan unos a otros y hasta que triunfan tanto sobre su propia confusión personal como sobre la que reina en la galaxia. En estas páginas, el lector obtendrá una comprensión más profunda de la imperfecta pero noble familia que tuvo un papel protagonista en la caída de la República y en la victoria definitiva de la Alianza Rebelde sobre la tiranía del Imperio.",
    "year": 2022,
    "authors": [
      "Kristen Baver"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 215
  },
  {
    "title": "ESTELAR",
    "isbn": "9788417347741",
    "synopsis": "La continuación de Escuadrón, la nueva saga epica de Brandon Sanderson. Este es el segundo libro de una serie epica sobre una chica que guarda un secreto en un peligroso mundo en guerra por el futuro de la humanidad. En el continúan las aventuras de Spensa Nightshade, la joven piloto que ha conseguido un puesto en el escuadrón de defensa de la humanidad contra los ataques alienígenas. En realidad, ella siempre quiso ser piloto: poder probar que es una heroína, como su padre. Y aunque llegó a lo más alto, los secretos que desenmascaró sobre su padre fueron aplastantes. Los rumores sobre su cobardía resultaron ciertos. Abandonó su vuelo durante la batalla contra los Krell. Peor aún... se volvió contra su equipo y los atacó. Sin embargo, Spensa está segura de que hay aún más por descubrir en esa historia. Y, si es necesario, viajará hasta el fin de la galaxia para salvar a la humanidad.",
    "year": 2020,
    "authors": [
      "Brandon Sanderson"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 218
  },
  {
    "title": "STAR WARS MAESTRO Y APRENDIZ (NOVELA)",
    "isbn": "9788491743583",
    "synopsis": "Novela por la autora súper ventas Claudia Gray (Estrellas Perdidas, Linaje, Leia: Princesa de Alderaan.Cuando el Jedi Rael Averross, otro ex alumno de Dooku, solicita su ayuda con una disputa política, Jinn y Kenobi viajan a la corte real de Pijal para lo que podría ser su misión final juntos. Lo que debería ser una simple tarea se nubla rápidamente por el engaño y por visiones de desastres violentos que se apoderan de la mente de Qui-Gon.A medida que crece la fe de Qui-Gon en la profecía, se pone a prueba la fe de Obi-Wan en él, así como surge una amenaza que exigirá que el Maestro y el aprendiz se unan como nunca antes, o se dividan para siempre.",
    "year": 2020,
    "authors": [
      "Claudia Gray"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 219
  },
  {
    "title": "LA UTOPIA LARGA (SAGA LA TIERRA LARGA 4)",
    "isbn": "9788401019333",
    "synopsis": "La Utopía Larga es la esperada cuarta entrega de la saga «La Tierra Larga», una aclamadísima colaboración entre los dos gigantes de la ficción especulativa Terry Pratchett y Stephen Baxter, que ya lleva vendidos más de un millón de ejemplares en todo el mundo.Año 2045. La humanidad ha hecho frente a todo tipo de cataclismos y sigue tratando de salir adelante en el antiguo planeta de Datum. Desde que la revolución tecnológica le permitió acceso a las nuevas Tierras, nada ha vuelto a ser lo mismo.Ni siquiera para Lobsang, que, convertido en un superordenador viejo y estropeado, trata de pasar por humano en un mundo remoto y cree estar llevando una vida de lo más corriente, la de un hombre de familia en New Springfield.",
    "year": 2017,
    "authors": [
      "Stephen Baxter"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 230
  },
  {
    "title": "STAR WARS. DISCIPULO OSCURO",
    "isbn": "9788491461654",
    "synopsis": "Novela Canon, basada en Star Wars: las guerras Clon.En la guerra por el control de la galaxia entre los ejércitos del lado oscuro y la República, el antiguo maestro Jedi convertido en el despiadado lord Sith Conde Dooku emplea tácticas cada vez más brutales. Cuando Dooku ordena la masacre de una flotilla de indefensos refugiados, el Consejo Jedi comprende que no tiene más remedio que tomar acciones drásticas: perseguir al hombre responsable de tantas atrocidades de guerra, el mismísimo Conde Dooku. Pero el siempre escurridizo Dooku es una presa peligrosa incluso para el más hábil de los cazadores.",
    "year": 2017,
    "authors": [
      "Christie Golden"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 231
  },
  {
    "title": "STAR WARS AHSOKA (NOVELA)",
    "isbn": "9788491730095",
    "synopsis": "¡Por fin llega la novela de Ahsoka! ¡Descubre qué le ocurrió después de abandonar la Orden Jedi!Los fans llevan tiempo preguntándose qué le ocurrió a Ahsoka después de abandonar La Orden Jedi durante el fin de Las Guerras Clon y antes de reaparecer como el misterioso operativo Fulcrum en Rebels. Al fin, su historia será contada. Siguiendo sus vivencias con los Jedi y la devastación provocada por la Orden 66, Ahsoka siente que no podrá formar parte de otra alianza nunca más. Pero su deseo de combatir el mal del Imperio y proteger aquellos que lo necesitan la llevará hasta Bail Organa y la Alianza rebelde.",
    "year": 2018,
    "authors": [
      "E.k. Johnston"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 235
  },
  {
    "title": "BATTLE ROYALE",
    "isbn": "9788445005934",
    "synopsis": "La novela que inspiró los \"todos contra todos\" de videojuegos tan populares como Fortnite o películas como LOS JUEGOS DEL HAMBRE.En la República del Gran Oriente Asiático está prohibido elrock, esa música decadente. Los jóvenes crecen en un estadototalitario y controlador que promueve la competitividad. Comomedida de control de rebeliones, la administración poneen marcha el Programa: cada año, 50 clases de distintos institutosson elegidas para luchar a muerte en la BATTLE ROYALE.Los alumnos elegidos son aislados en una isla. Las normasdel juego son estrictas: no pueden escapar, no pueden contactarcon el exterior, y solo puede quedar uno.Reedición de esta obra clásica de terror japonés en la que se basó la popular película homónima. La historia es un reflejo, a la vez que una crítica, de la sociedad japonesa, tremendamente competitiva e individualista.",
    "year": 2020,
    "authors": [
      "Koushun Takami"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 238
  },
  {
    "title": "LOS DESPOSEIDOS",
    "isbn": "9788445009307",
    "synopsis": "Shevek, un físico brillante, originario de Antares, un planeta aislado y «anarquista», decide emprender un insólito viaje al planeta madre Urras, en el que impera un extraño sistema llamado el «propietariado». Shevek cree por encima de todo que los muros del odio, la desconfianza y las ideologías, que separan su planeta del resto del universo civilizado, deben ser derribados. En este contexto la autora explora algunos de los problemas de nuestro tiempo: la posición de la mujer en la estructura social, la complejidad de las relaciones humanas, los méritos y las promesas de las ideologías, y las perspectivas del idealismo político en el mundo actual.",
    "year": 2020,
    "authors": [
      "Ursula K. Le Guin"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 242
  },
  {
    "title": "EL DIA DE LOS TRIFIDOS",
    "isbn": "9788413621487",
    "synopsis": "Si sabes que es miércoles y la mañana empieza como si fuera un domingo, algo muy grave tiene que estar pasando en alguna parte. De esta forma tan inocua comienza una de las novelas más famosas de catástrofes. Al día siguiente de que una lluvia de meteoritos caiga sobre Inglaterra, Bill Masen es uno de los pocos afortunados que conserva la vista. Londres está llena de hombres y mujeres que vagan en busca de ayuda y en algunos casos tratan de esclavizar a quienes todavía pueden ver. Pero en este mundo postapocalíptico tienen que sobrevivir a otra amenaza: los trífidos, unas plantas carnívoras de más de dos metros de alto, que pueden desplazarse y que poseen aguijones letales. ¿Tienen los seres humanos alguna posibilidad ante un enemigo así?",
    "year": 2021,
    "authors": [
      "John Wyndham"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 244
  },
  {
    "title": "CUCHILLO DE AGUA",
    "isbn": "9788415831914",
    "synopsis": "Una escalofriante aventura futurista que arroja nueva luz a nuestra forma de vivir,Cuchillo de agua es la primera novela adulta de Paolo Bacigalupi después de la aclamadísima, multipremiada e internacionalmente exitosaLa chica mecánica.LÉELA ANTES DE QUE LA REALIDAD SUPERE LA FICCIÓN.Cuando el río Colorado se seca, el sur de Estados Unidos se convierte en el escenario desértico de una guerra por el agua.En un futuro no muy lejano, tras siglos de sobreexplotación, el río Colorado está secándose.",
    "year": 2016,
    "authors": [
      "Paolo Bacigalupi"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 252
  },
  {
    "title": "STAR WARS NOVELA: DARTH PLAGUEIS",
    "isbn": "9788416090105",
    "synopsis": "Un lord Sith con un poder definitivo.sobre la vida y la muerte.Darth Plagueis, como todos los lores Sith previos a él, ansía el poder. Pero a diferencia de cualquier otro lord Sith posee un poder definitivo.sobre la vida y la muerte. Darth Sidious: domina secretamente el poder del lado oscuro mientras públicamente asciende al puesto más alto del gobierno.Uno desea ser el gobernante supremo; el otro sueña con vivir eternamente. Juntos destruirán a los Jedi y regirán la galaxia. A no ser que la despiadada tradición Sith termine siendo su perdición.",
    "year": 2014,
    "authors": [
      "James Luceno"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 259
  },
  {
    "title": "QUI VOL EL PANGLOS?",
    "isbn": "9788494363184",
    "synopsis": "¿Què passaria si en una Catalunya futura, en fràgil equilibri lingüístic entre el català, el castellà, langlès i làrab, sinventés un aparell, anomenat panglòs, que permetés a la persona que el porta entendre tothom, i fer-se entendre amb tothom, sabent només la seva llengua?En aquesta novel·la, que ara per ara és de ciència-ficció, lautor reflexiona sobre limpacte que un traductor automàtic portàtil com el panglòs podria tenir en els usos lingüístics a Catalunya. El lector hi trobarà descrites algunes situacions que lincitaran a reflexionar. Com afectaria el panglòs al català? Qui voldria usar-lo? Qui voldria que no susés? Si llengua i identitat estan relacionats dalguna manera, quin efecte podria tenir sobre la identitat catalana?",
    "year": 2015,
    "authors": [
      "Antoni Olive Ramon"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 260
  },
  {
    "title": "NAHUM (CABALLO DE TROYA 7)",
    "isbn": "9788408108108",
    "synopsis": "La verdadera historia de Juan, el Bautista.Nahum-la ciudad de Jesús- abre una nueva etapa en la serie «Caballo de Troya». En esta séptima entrega del mayor norteamericano que viajó a la Palestina del siglo I todo cambia. Descubrir la trama no es aconsejable. Usted, probablemente, no dará crédito a lo que lea en sus páginas. Quizá tenga razón, pero no olvide que la verdad supera siempre a la ficción. Sí, podemos asegurarle que si se decide a leerNahum, sus certezas religiosas saltarán por los aires, afortunadamente. Nada de lo que se considera oficial y ortodoxo guarda relación con lo escrito en «Caballo de Troya».",
    "year": 2011,
    "authors": [
      "J.j. Benitez"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 263
  },
  {
    "title": "JERUSALEN (CABALLO DE TROYA 1)",
    "isbn": "9788408108047",
    "synopsis": "La pasión y muerte fue peor de lo que cuentan.El autor pone al descubierto una documentación secreta–clasificada como top secret por el Pentágono–con nuevos y sorprendentes datos sobre la figura y la obra de Jesús de Nazaret. Las revelaciones que aporta son tan rigurosas como desconcertantes.",
    "year": 2011,
    "authors": [
      "J.j. Benitez"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 264
  },
  {
    "title": "CTS THE HORUS HERESY 1: HORUS SEÑOR DE LA GUERRA (COMIENZA TU SERIE)",
    "isbn": "9788445010648",
    "synopsis": "Los orígenes de Warhammer 40.000 a un precio especial.En esta serie se relatan hechos que suceden 10000 años antes que los referidos en las novelas de Warhammer 40000. Por este motivo se trata de una serie imprescindible para los aficionados que quieran conocer el origen de episodios y personajes de otras novelas.Condiciones de la promoción:*Tirada limitada, especial sin sobrecubiertas.*Promoción solo para el número 1 (resto de entregas a precio habitual).",
    "year": 2022,
    "authors": [
      "Dan Abnett"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 269
  },
  {
    "title": "SOBRE HORMIGAS Y DINOSAURIOS",
    "isbn": "9788418037498",
    "synopsis": "El autor deEl problema de los tres cuerposregresa a la ciencia ficción con una advertencia ecológica en forma de fábula: la historia de unos pobres dinosaurios que no escucharon los avisos de las hormigas sobre un inminente desastre ambiental.La inteligencia es un destello fugaz en la larga noche de la historia cósmica. Que pueblen la tierra no una sino dos especies inteligentes al mismo tiempo pone en cuestión cualquier cálculo de probabilidades. El hecho de que esas dos especies, tan distintas como complementarias, forjen una alianza que a su vez enciende una civilización desafía toda lógica.Los inicios de la alianza entre las hormigas y los dinosaurios fueron humildes, pero de ella surgieron la escritura, las matemáticas, los ordenadores e incluso los viajes espaciales.",
    "year": 2022,
    "authors": [
      "Cixin Liu"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 273
  },
  {
    "title": "EL HIJO VENGADOR: AMANECER DE FUEGO",
    "isbn": "9788445011683",
    "synopsis": "ESTO ES LA ERA INDOMITUS? Una penetrante oscuridad se cierne sobre la galaxia y las tropas del Caos avanzan inexorablemente. Para sobrevivir, la humanidad se verá obligada a contraatacar y recuperar lo que una vez fue suyo. Bajo el mandato del Primarca Resucitado, Roboute Guilliman, la Cruzada Indomitus se embarcará en una campaña militar de magnitudes desconocidas hasta ahora. Así, el Hijo Vengador guiará a sus flotas desde el Mundo Trono de Terra con un solo objetivo en mente: salvar a la humanidad de la extinción. Mientras tanto, miles de naves surcan el vacío gélido y la Señora de la Flota VanLeskus dirige su atención al Brazo Machorta, una zona asediada por una terrible Cruzada de Masacre de los Dioses del Caos. El resultado de esta contienda marcará el destino de la Cruzada Indomitus y de la misión desesperada del Grupo de Asalto Santa Aster, liderado por el teniente Messinius.",
    "year": 2021,
    "authors": [
      "Guy Haley"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 278
  },
  {
    "title": "STAR WARS THRAWN ASCENDENCIA Nº 01- EL CAOS CRECE (NOVELA)",
    "isbn": "9788413416892",
    "synopsis": "Más allá de los confines de la galaxia se encuentran las Regiones Desconocidas: caóticas, no cartografiadas y prácticamente intransitables, cargadas de secretos ocultos y peligros. Y entre ese caos turbulento se refugia la Ascendencia, hogar de los enigmáticos chiss y las Nueve Familias Regentes que los lideran. La paz de la Ascendencia, una isla de calma y estabilidad, se rompe tras un audaz ataque contra la capital chiss que no deja ninguna pista sobre el enemigo. Desconcertada, la Ascendencia le encarga a uno de sus oficiales militares más brillantes que descubra al asaltante desconocido? un recluta de orígenes humildes, pero que es adoptado por la poderosa familia de los Mitth, que lo llamará Thrawn. Respaldado por el poder de la Flota Expansionaria y ayudado por su colega almirante Ar?alani, Thrawn empieza a encontrar las respuestas que busca.",
    "year": 2021,
    "authors": [
      "Timothy Zahn"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 282
  },
  {
    "title": "STAR WARS. THE HIGH REPUBLIC: TORMENTA CRECIENTE (NOVELA)",
    "isbn": "9788411121156",
    "synopsis": "Sigue el evento estelar más exitoso de la galaxia.La galaxia está de celebración. Los oscuros días que en torno al desastre hiperespacial han quedado atrás y la canciller Lina Soh avanza la última de sus GRANDES OBRAS. La Feria de la República será su gran logro, una celebración de paz, unión y esperanza en el fronterizo mundo de Valo.Pero un horror implacable asoma por el horizonte. Uno por uno, los planetas van cayendo a medida que el carnívoro DRENGIR devora toda vida a su paso. Mientras la maestra Jedi Avar Kriss lidera la batalla contra esta amenaza, las fuerzas Nihil se reúnen en secreto para la siguiente fase del diabólico plan de MARCHION RO.Sólo los nobles CABALLEROS JEDI se interponen en su camino, pero ni siquiera los protectores de la luz y la vida están preparados para enfrentarse a la oscuridad que les acecha…",
    "year": 2022,
    "authors": [
      "Cavan Scott"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 294
  },
  {
    "title": "SOMBRAS VERDES, BALLENA BLANCA",
    "isbn": "9788445007839",
    "synopsis": "Una cinematográfica y animal aventura.En 1953, Ray Bradbury, entonces un escritor relativamente poco conocido, fue llamado a Irlanda para escribir el guión de Moby Dick, una película del ya famoso director John Huston. Bradbury permaneció siete meses en Irlanda y de esta experiencia nacieron algunos cuentos notables como «La carrera del himno» y «El mendigo del puente O''Connell».EnSombras verdes, ballena blanca Bradbury mezcla estos y otros episodios en un gran cuadro y cuenta vívidamente toda la historia: las aventuras del joven asombrado (en parte Bradbury mismo) que enfrenta al extraordinario director, lucha con la bestia mítica, y—con la ayuda entusiasta de los parroquianos de la taberna de Finn—llega a conocer los misteriosos secretos de los irlandeses.",
    "year": 2022,
    "authors": [
      "Ray Bradbury"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 297
  },
  {
    "title": "STAR WARS COSECHA ROJA",
    "isbn": "9788491739067",
    "synopsis": "La era de la Antigua República es una época oscura y peligrosa en la que los Caballeros Jedi se enfrentan a los lores Sith y a sus despiadados ejércitos. Pero los Sith tienen planes inquietantes, entre ellos la puesta en práctica del sueño fanático de Darth Scabrous.A diferencia de esos otros Jedi marginados al Cuerpo Agrícola, Hestizo Trace posee un extraordinario talento para la Fuerza: un don con las plantas. De pronto, su tranquila existencia se ve alterada por la llegada de un emisario de Darth Scabrous. La singular orquídea negra que ha estado cuidando es el ingrediente que falta en una antigua fórmula Sith que promete concederle a Darth Scabrous su mayor deseo.Pero en el corazón de la fórmula hay un virus desconocido hasta el momento que no solo mata, sino que transforma.",
    "year": 2019,
    "authors": [
      "Joe Schreiber"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 303
  },
  {
    "title": "MAESTRO ZACHARIUS O EL RELOJERO QUE PERDIO SU ALMA",
    "isbn": "9788494956843",
    "synopsis": "En la revista Musée des familles, Verne publicó por primera vez en 1854 el relato Maître Zacharius ou l''Horloger qui avait perdu son âme. Posteriormente, en 1874, se publicó en una edición de Hetzel junto al relato Le Docteur Ox, Un Drame dans les airs y Un Hivernage dans les glaces. En este relato, Verne bebe de la obra de Poe y Hoffmann para construir un relato fantástico donde el maestro Zacharius, relojero de gran renombre en la ciudad de Ginebra, desesperado por el hecho de que todos sus relojes dejan de ir a la hora, trata de hacer un pacto con el Tiempo, dándole a su hija en matrimonio y así a cambio poder arreglar sus relojes.",
    "year": 2019,
    "authors": [
      "Julio Verne"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 307
  },
  {
    "title": "LA HEREJIA DE HORUS 2: FALSOS DIOSES",
    "isbn": "9788445003107",
    "synopsis": "Continúa la serie que explica los orígenes de Warhammer 40000En esta serie se relatan hechos que suceden 10000 años antes que los referidos en las novelas de Warhammer 40000. Por este motivo se trata de una serie imprescindible para los aficionados que quieran conocer el origen de episodios y personajes de otras novelas.",
    "year": 2016,
    "authors": [
      "Graham Mcneill"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 317
  },
  {
    "title": "LA HEREJIA DE HORUS 1: HORUS, SEÑOR DE LA GUERRA",
    "isbn": "9788445003091",
    "synopsis": "En esta serie se relatan hechos que suceden 10000 años antes que los referidos en las novelas de Warhammer 40000. Por esteá motivo se trata de una serie imprescindible para los aficionados que quieran conocer el origen de episodios y personajes de otras novelas.",
    "year": 2016,
    "authors": [
      "Dan Abnett"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 318
  },
  {
    "title": "LA HEREJIA DE HORUS 9: MECHANICUM",
    "isbn": "9788445003176",
    "synopsis": "Una de las mejores novelas de esta serie publicadas hasta la fechaLas llamas de la traición se extienden por todo el Imperio. Horus moviliza a todas las fuerzas que le son leales y planea destruir a todas aquellas que se atrevan a enfrentarse a él. Se está librando una batalla por el corazón y el alma de todas las fuerzas imperiales: los Astartes, el Ejército Imperial, las legiones de titanes, y muchas más. En esta obra épica, Graham McNeill narra el relato de la guerra civil que se libró en Marte y la génesis del Mechanicum Oscuro.",
    "year": 2016,
    "authors": [
      "Graham Mcneill"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 319
  },
  {
    "title": "LA HEREJIA DE HORUS 13: NEMESIS",
    "isbn": "9788445003213",
    "synopsis": "Dos años despues de la horrorosa matanza de Isstvan IV, Horus le declara abiertamente la guerra al Imperio. Pero en las sombras del Palacio del Emperador un grupo de sujetos poderosos se reúne. Su plan es enviar un equipo de asesinos que ejecute al Architraidor Horus y así acabar con la guerra por el dominio de la galaxia antes de que ni siquiera comience. Lo que no saben es que Horus y sus aliados ya han iniciado su propio plan, igual de siniestro, para acabar con el Emperador.",
    "year": 2016,
    "authors": [
      "James Swallow"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 320
  },
  {
    "title": "STAR WARS EL RESURGIR DE LA FUERZA OSCURA (NOVELA)",
    "isbn": "9788491460695",
    "synopsis": "Segunda novela del la trilogía de Thrawn.Durante la frágil República nacida tras la derrota deDarth Vader, el emperador y la maléfica Estrella de la Muerte, se encuentra amenazada desde dentro y desde fuera. El despiadado gran almiranteThrawn ha tomado el mando de los restos de la flota imperial y lanzado una masiva campaña con el propósito de destruir a la República. Entretanto, las disensiones y las ambiciones personales amenazan con desmembrar a la República. Mientras laPrincesa Leia, embarazada de gemelosJedi, arriesga su vida para lograr que una raza alienígena orgullosa y mortífera se alíe con la República. Por su lado,Han y Lando Calrissian luchan contra el tiempo para descubrir pruebas de la traición que se gesta en el seno del Consejo de la República. No obstante lo más peligroso de todo es un nuevo Jedi Oscuro, surgido de las cenizas de un pasado encubierto, consumido por la amargura...",
    "year": 2017,
    "authors": [
      "Timothy Zahn"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 324
  },
  {
    "title": "EL DESPERTAR DEL LEVIATAN (THE EXPANSE 1)",
    "isbn": "9788466660150",
    "synopsis": "La novela en que se basa la primera temporada de la serie de TV de Syfy The ExpanseLa humanidad ha colonizado el Sistema Solar: Marte, la Luna, el cinturón de asteroides y más allá, pero las estrellas aún están fuera de nuestro alcance.Jim Holden es segundo de a bordo de un transportador de hielo que realiza misiones entre los anillos de Saturno y las estaciones mineras del Cinturón. Cuando su tripulación y él se topan con la Scopuli, una nave abandonada, descubren un secreto que desearían no haber encontrado. Un secreto por el que alguien sería capaz de matar, matar a una escala que Jim y su tripulación no imaginan. La guerra en el Sistema Solar está a punto de comenzar, a menos que sean capaces de descubrir quién abandonó la nave y por qué.El inspector Miller busca a una chica. Una chica entre mil millones, pero los padres de ella son gente adinerada, y el dinero lo es todo.",
    "year": 2016,
    "authors": [
      "James S. A. Corey"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 325
  },
  {
    "title": "GREEN TOWN 1: EL VINO DEL ESTIO",
    "isbn": "9788445007464",
    "synopsis": "Celebrando en centenario Bradbury con una reedición en la nueva colección de Bibliotecas de AutorEn tres prodigiosos meses de 1928, Douglas Spaulding observa, escucha y saborea las sorpresas rituales de un verano especial: el descubrimiento de la vida y la muerte, el último tranvía, la aparición de las hamacas en los porches, la cosecha del vino del estío... pero su verano también está lleno de máquinas extraordinarias y magia misteriosa. . Miniserie de dos entregas, que se publicarán simultáneamente en mayo. «Ningún otro escritor desde Mark Twain ha descrito la vitalidad y la inocencia de una pequeña ciudad americana con tan fina y madura percepción.»—Saturday Review.",
    "year": 2020,
    "authors": [
      "Ray Bradbury"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 329
  },
  {
    "title": "VISIONES DE ROBOT",
    "isbn": "9788401496714",
    "synopsis": "Este libro extraordinario resume medio siglo de pensamiento acerca de los robots y la robótica. Desde el mismo Robbie hasta los relatos de Susan Calvin, la primera robopsicóloga, pasando por Stephen Byerley, el robot humanoide, y el equipo de detectives formado por un hombre y un robot, Lije Bayley y Daneel Olivaw, encontramos aquí los momentos clave en la historia de ficción de las relaciones entre el hombre y el robot",
    "year": 1997,
    "authors": [
      "Isaac Asimov"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1235
  },
  {
    "title": "UN FUEGO SOBRE EL ABISMO",
    "isbn": "9788490180792",
    "synopsis": "Una expedición humana se encuentra muy lejos de su zona, estudiando un archivo de datos que podría contener riquezas inimaginables para la joven y ambiciosa población del reino de Straumli. Desgraciadamente, mientras llevan a cabo sus investigaciones, despiertan a la Plaga, un superente maligno que está dispuesto a fagocitarse en parte con tal de que los humanos no escapen, tal y como lo han planeado en secreto. La Plaga logra destruir una de las naves, pero la otra escapa con un centenar de niños criogenizados, una familia y una contramedida, quizá la única cosa en el universo a la que tema la maligna entidad.",
    "year": 2013,
    "authors": [
      "Vernor Vinge"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1248
  },
  {
    "title": "LES POMES DAURADES DEL SOL",
    "isbn": "9788482646954",
    "synopsis": "Possedor d’un dels talents mes visionaris del segle XX, Ray Bradbury ens va deixar alguns contes que són obres mestres del genere. En aquest volum trobarem trenta-dos relats cabdals que revelen el Bradbury mes imaginatiu, pero sobretot hi retrobarem un escriptor tendre, capaç d’explicar, amb la historia d’un individu o d’un fet mínim, tota una visió dramàtica sobre l’home i allo que l’espera. Un autor que ens ha dotat de figures i símbols que ens ajuden a entendre l’univers que habitem, com ara el celebre \"efecte papallona\", expressat amb gran encert en el conte \"El so d’un tro\". Gràcies a Bradbury retrobem allo meravellós, el mes terrible i el mes sublim, l’inesperat i el malson que es transforma en una visió obsessionant i lúcida sobre la nostra condició.",
    "year": 2014,
    "authors": [
      "Ray Bradbury"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1263
  },
  {
    "title": "SOSPECHA",
    "isbn": "9788499674438",
    "synopsis": "Derec, el protagonista de esta saga, se ve envuelto en un asesinato junto con una misteriosa acompañante y su vida correrá serio peligro.En una ciudad habitada por robots Derec continúa amnésico acompañado de Katherine, una misteriosa chica que sabe quién es Derec y de dónde viene pero que se niega a decírselo, ellos son los únicos sospechosos de asesinato en una ciudad habitada sólo por robots. Por si esto no fuera suficiente, una tormenta amenaza con convertir Robot City en un lugar inhabitable incluso para los propios robots.",
    "year": 2013,
    "authors": [
      "Mike Mcquay"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1288
  },
  {
    "title": "KAT OS: LA ZARINA DEL TORMENTO",
    "isbn": "9788494110351",
    "synopsis": "Toda gran leyenda para ser forjada tiene su inicio en una historia que debe trascender a la cognición y el raciocinio comunes. Kät’Os: la Zarina del Tormento (Obertura a El lamento Ksäg’en) es una trepidante aventura de ciencia ficción, plagada de fantasía y con lenguaje propio. Conoce el origen de El lamento Ksäg’en, la lucha eterna entre el bien y el mal, un viaje continuo para mantener el equilibrio del Universo. Equilibrio que está pendiente de un hilo, pese a todo, los Siete Supremos y sus aliados lucharán por volver a estabilizar la balanza, y no será fácil de conseguir pues tendrán que enfrentarse a duras pruebas y contiendas frente a un ejército de incombustibles sombras comandado por una malvada zarina que se empeña en imponer a toda costa el caos y la destrucción.",
    "year": 2013,
    "authors": [
      "Juan A. Pajuelo"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1291
  },
  {
    "title": "METAMORFOSIS",
    "isbn": "9788415747215",
    "synopsis": "Una fantástica metrópolis de robots situada en un planeta alienígena se encuentra en peligro. Unos sereslobo atacan la ciudad bajo la dirección de un extraño robot, que parece no conocer las Leyes de la Robótica. Derec está ligado a la ciudad robótica por una desconcertante infección de microchips en su sangre. Ahora su misión es enfrentarse a este insólito robot que no comprende quiénes son exactamente esos “humanos” cuyas órdenes ha de obedecer en virtud de las Leyes de la Robótica que le han programado.",
    "year": 2013,
    "authors": [
      "Stephen Leigh"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1299
  },
  {
    "title": "CYBORG",
    "isbn": "9788499674452",
    "synopsis": "Derec, el protagonista de esta inmortal saga deberá hacer frente a un cyborg con problemas psicológicos y una sed de destrucción más propia de un humano.EnCyborgDerec y Katherine, la misteriosa acompañante del protagonista, encuentran al único superviviente de una nave de pasajeros que ha tenido que hacer un aterrizaje de emergencia en el planeta, un planeta habitado únicamente por robots. Lo que ellos no saben es que Jeff, el superviviente, es en realidad un cyborg con problemas psicológicos y unas ansias de destrucción insaciables. Derec también tendrá que descubrir la verdadera identidad de su acompañante Katherine y encontrar el modo de abandonar ese misterioso planeta habitado por robots y sin rastro de humanos por ninguna parte.William F.",
    "year": 2013,
    "authors": [
      "William F. Wu"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1306
  },
  {
    "title": "EL SIGLO MECANICO: CLEMENTINE",
    "isbn": "9788490180495",
    "synopsis": "La popularidad de Maria Isabella Boyd como espía confederada la inhabilita para desempeñar semejante labor, por lo que empieza a trabajar, muy a su pesar, para la agencia nacional de detectives Pinkerton de Chicago. La nave Clementine, un dirigible de transporte federal con un cargamento altamente secreto, debe llegar sin demora a su destino, pero está siendo salvajemente acosada. Su incansable perseguidor es el pirata aéreo Croggon Hainey, un esclavo fugitivo buscado por las autoridades desde hace quince años. El deber de Maria es atraparlo, pero cuando fuerzas ajenas conspiran contra ambos, deciden arriesgarse y formar una alianza? Alguien, en algún lugar, va a lamentar el día en que se cruzó con ellos.",
    "year": 2013,
    "authors": [
      "Cherie Priest"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1321
  },
  {
    "title": "GUERRA MUNDIAL Z",
    "isbn": "9788415828006",
    "synopsis": "Max Brooks ha dedicado varios años a recorrer el mundo en busca de todos los testimonios que ahora reúne aquí sobre la guerra mundial zombi. Por insólito que parezca este libro, que algunos tildan de novela demasiado realista, es la parte censurada del informe que le encargó Naciones Unidas para que quedara memoria de «La Crisis», los «Años Oscuros» o la «Plaga Andante», principalmente conocida como Guerra Mundial Z. Al parecer había «demasiado factor humano».Este libro aclara realmente cómo el doctor Kwang Jingshu descubrió los primeros casos y se destaparon las pruebas ocultadas por el gobierno chino sobre el gran estallido. También cómo surgió y se propagó el controvertido Plan Naranja de supervivencia, fruto de un oscuro cerebro del apartheid sudafricano.",
    "year": 2013,
    "authors": [
      "Max Brooks"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1335
  },
  {
    "title": "ALIANZA",
    "isbn": "9788415747246",
    "synopsis": "Robot City ha sido recuperada, pero, ¿por cuánto tiempo? Tres renegados, robots mutantes, amenazan con destruir la ciudad. ¿Se atreverán a desobedecer las Tres Leyes? Derec y Ariel deben convencer a los renegados de que una alianza, no una revolución de los robots es lo mejor. ¿Lo lograrán? ¡El futuro de los seres humanos y de los robots espera la respuesta!",
    "year": 2013,
    "authors": [
      "Jerry Oltion"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1342
  },
  {
    "title": "REFUGIO",
    "isbn": "9788499674490",
    "synopsis": "Una nueva aventura de Derec que en esta ocasión deberá hacer todo lo posible por salvar la vida de Ariel en un planeta superpoblado.Derec y Ariel consiguen salir, enRefugio, de Robot City utilizando un portal y llegan a la Tierra, el único lugar en el que se puede salvar la vida de Ariel. La Tierra es un país superpoblado en el que existen ciudades subterráneas, Derec tendrá que elegir entre las cavernas de acero y los confines de una metrópolis ya que está enfrentado a las sociedades subterráneas de nuestro planeta.",
    "year": 2013,
    "authors": [
      "Rob Chilson"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1348
  },
  {
    "title": "ODISEA",
    "isbn": "9788499674414",
    "synopsis": "El comienzo de una de las grandes sagas de la ciencia ficción, las Leyes de la Robótica de Asimov puestas a prueba una vez más.El universo de Asimov y todas las cuestiones éticas relacionadas con la robótica que fue capaz de crear no se agotan en su obra,Odisea, perteneciente a la sagaRobot Cityexplora nuevamente los límites de la robótica. Supervisada directamente por Asimov, la novela nos presenta a Derec, un misterioso astronauta que despierta, amnésico, dentro de una cápsula de salvación en un asteroide helado. Los únicos habitantes de este curioso asteroide son unos robots mineros que trabajan sin descanso en la búsqueda de un tesoro, Derec deberá enfrentarse a los robots y salir del asteroide.Michael P.",
    "year": 2013,
    "authors": [
      "Michael P. Kube-Mcdowell"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1349
  },
  {
    "title": "ACRONOS: ANTOLOGIA STEAMPUNK (VOL. 1)",
    "isbn": "9788494074783",
    "synopsis": "CARTORCE AUTORES SE HAN UNIDO PARA, SIN DEJAR DE MIRAR HACIA EL FUTURO, RECUPERAR CON NOSTALGIA EL ROMANTICISMO YA PERDIDO DEL SIGLO XIX, COMBINANDO LO MEJOR DE DOS MUNDOS Y DANDOLES CADA UNO SU PARTICULAR VUELTA DE TUERCA",
    "year": 2013,
    "authors": [
      "Paulo Cesar Ramirez Villaseñor"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1356
  },
  {
    "title": "LOS TINTADOS",
    "isbn": "9788494096136",
    "synopsis": "Una serie de acontecimientos devela que un gran número de habitantes de la tierra ha sido manipulado genéticamente por una especie extraterrestre. Para proteger la continuidad de la humanidad, los gobiernos deciden exterminar a todos los afectados. Los Tintados es la primera parte de la peligrosa historia de amor entre un híbrido llamado Rafael y una humana llamada Sofía.",
    "year": 2013,
    "authors": [
      "B. B. Castro"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1368
  },
  {
    "title": "ARKHAM",
    "isbn": "9788494074745",
    "synopsis": "Arkham. Relatos de horror cósmico\" es una antología que nace fruto de la colaboración entre Tyrannosaurus Books y el blog Infectados dirigido por Macu Marrero. Se trata de una antología de 15 textos inéditos que giran entorno a Arkham y los mitos lovecraftianos, relatos repletos de terror, misterios y hechos inexplicables. Envuelta en un ambiente onírico mezclado con humedad fluvial, entre grumos de un oscuro pasado de brujería y veneración a abominables entes ultraterrenos, Arkham muestra sus centenarias entrañas en un viaje temporal donde se van sucediendo destinos inexorables e inevitables encuentros, libros prohibidos y peligrosas invocaciones, conciencias insanas y crímenes aberrantes... En la calle solitaria sus pasos resuenan, han llegado al umbral y la puerta se entreabre, pasen y tiemblen.",
    "year": 2013,
    "authors": [
      "Macu Marrero"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1369
  },
  {
    "title": "LOS PRIMEROS DE TANITH",
    "isbn": "9788448044435",
    "synopsis": "En el futuro de pesadilla de WARHAMMER 40.000, la humanidad se encuentran al borde de la extinción. El imperio, que abarca galaxias, está repleto de peligros y en el sistema solar Sabbat, infestado por el Caos, el Comisario Imperial Gaunt debe guiar a sus hombres tanto en el combate contra las fuerzas del Caos como contra regimientos rivales.",
    "year": 2009,
    "authors": [
      "Dan Abnett"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1380
  },
  {
    "title": "GRANDES NOVELAS (CONTIENE: LA MAQUINA DEL TIEMPO; LA ISLA DEL DOC TOR MOREAU; EL HOMBRE INVISIBLE; LA GUERRA DE LOS MUNDOS)",
    "isbn": "9788490064474",
    "synopsis": "En este volumen presentamos las cuatro novelas fundamentales de H. G. Wells, centradas en temas que siguen preocupando en la actualidad y continúan marcando el camino de la investigación científica, con todo lo que tienen de positivo y de negativo: el viaje en el tiempo, la invasión extraterrestre, la enajenación mental que puede provocar la ciencia y la manipulación genética. Son cuatro novelas, en definitiva, que siguen teniendo vigencia a principios del siglo XXI.",
    "year": 2012,
    "authors": [
      "Herbert George Wells"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1387
  },
  {
    "title": "A REY MUERTO",
    "isbn": "9788494031168",
    "synopsis": "Más allá de la simple aventura por la creación de una sociedad tras una catástrofe global, el lector se enfrentará en esta nueva novela del célebre hispanista Mills Fox Edgerton a cuestiones tan originales y difíciles de responder como cuál sería la pervivencia de la cultura fuera del marco de la propia civilización; o cuánto tiempo sobrevivirían en la memoria colectiva los símbolos sobre los que se asienta todo nuestro bagaje histórico. Mills nos invita a la recreación de una Urbe donde el azar decide quién debe estar allí tras una supuesta catástrofe que cierra una Gran Puerta, delimitando así el antiguo Estado del actual. Un nuevo mundo, una nueva forma de vida, una civilización en ciernes que se alimenta de los pocos recursos que le brinda el recuerdo de lo que fueron y ya no son.",
    "year": 2012,
    "authors": [
      "Mills Fox Edgerton"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1391
  },
  {
    "title": "ETERNA JUVENTUD",
    "isbn": "9788445000250",
    "synopsis": "2019. La humanidad es testigo del mayor descubrimiento científi co hasta la fecha: la cura para el envejecimiento. Tras un intenso debate político y moral, el gobierno decide poner la Cura al alcance de todo el mundo. La ansiada inmortalidad, sin embargo, tambien tiene sus pegas: el fin del matrimonio, programas gubernamentales de eutanasia, fanáticos pro-muerte, un nuevo e inquietante culto religioso y otras calamidades serán sólo el principio del fin.",
    "year": 2012,
    "authors": [
      "Drew Magary"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1406
  },
  {
    "title": "EL MEJOR DE LOS MUNDOS POSIBLES",
    "isbn": "9788490065129",
    "synopsis": "La humanidad se ha extendido y diversificado por el universo creando sociedades y culturas diferenciadas yoriginales que colaboran y recelan entre ellas. Un ataque por sorpresa destruye el planeta de una sociedad orgullosa yreservada, cuyos supervivientes no tienen más remedio que entrar en contacto con la cultura del mundo que los haacogido y con la que están lejanamente emparentados. Su deseo más profundo es preservar su forma de vida pero acabarándescubriendo que para conservar su cultura es posible que tengan que cambiarla para siempre.",
    "year": 2013,
    "authors": [
      "Karen Lord"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1413
  },
  {
    "title": "LLUVIA NEGRA",
    "isbn": "9788445077269",
    "synopsis": "Buscaban la fuente de energía definitiva. Encontraron una pesadilla real y milenaria.Una antigua leyenda indígena dice que en lo más profundo de la jungla del Amazonas, en la región «donde las muchas muertes caminan en la noche», habitan los Indele. Pero la brillante investigadora Danielle Laidlaw no cree en leyendas. Su empresa la envía al corazón de la selva amazónica con la excusa de una expedición arqueológica para conseguir lo que podría convertirse en la fuente de energía definitiva. Danielle no puede imaginar que su aventura se convertirá en una pesadilla espeluznante En la selva, ella y su equipo de investigadores descubrirán que el mayor peligro que les acecha no es el grupo de mercenarios que pretende robarles información, sino una amenaza mucho mayor que no les permitirá escapar tan fácilmente con el valioso descubrimiento.",
    "year": 2009,
    "authors": [
      "Graham Brown"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1421
  },
  {
    "title": "LUNA ES UNA CRUEL AMANTE",
    "isbn": "9788498005035",
    "synopsis": "Aunque sus abuelos fueron recluidos en su día en la colonia, Mannie nació libre y eso supone una gran diferencia. Como contratista privado, hace negocios con la Autoridad pero no figura en su nómina. El régimen de Luna es severo e injusto, la revolución se masca en el ambiente y se habla incluso de derrocar a la odiada Autoridad. Cuando Mannie ayuda a la preciosa Wyoming Knott a escapar de los guardaespaldas del Guardián, se encuentra de alguna manera en el centro de una rebelión sin esperanza. Aunque Mannie tiene un arma secreta: Mike es el ordenador más inteligente de la colonia, está conectado a toda clase de equipos útiles... Y Mannie es el mejor amigo de Mike.",
    "year": 2009,
    "authors": [
      "Robert A. Heinlein"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1436
  },
  {
    "title": "BESTIAS",
    "isbn": "9782706201431",
    "synopsis": "La fragmentación ideológica y la elevada tasa de paro amenazan la estabilidad de Estados Unidos. Los experimentos científicos con fines militares que consisten en mezclar el ADN humano con el de ciertos animales tocan a sufin por falta de financiación, y los mutantes son abandonados a su suerte, sin trabajo ni protección so cial, pues no se les considera humanos.En un clima de máxima tensión, violentos grupos de bárbaros y anarquistas luchan contra los agentes del Sindicato por la Ingeniería Social, quienes planean hacerse con el control total. Lo único que ambas facciones tienen en común es su odio hacia los leos. Todos están en contra de esas criaturas, mitad hombres, mitad animales, esos depredadores a quienes los hombres llaman bestias.",
    "year": 2014,
    "authors": [
      "John Crowley"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1452
  },
  {
    "title": "VESTIGIOS",
    "isbn": "9788445002155",
    "synopsis": "Todo principio tiene un finalEn Espejismo entramos por primera vez en el Silo, con Desolación descubrimos la historia de su creación y en Vestigios seremos testigos de su caída.La tercera y última entrega de las Crónicas del Silo recupera a su protagonista Juliette y da respuesta a todas las incógnitas que quedaron sin resolver en las dos primeras entregas.",
    "year": 2014,
    "authors": [
      "Hugh Howey"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1459
  },
  {
    "title": "TITAN",
    "isbn": "9788498004502",
    "synopsis": "Es el año 2095. Después de muchos meses de viaje, la gigantesca nave colonia Goddard por fin ha empezado a orbitar alrededor de Saturno, llevando una población de más de diez mil disidentes, rebeldes, extremistas y visionarios en busca de una nueva vida. Entre las misiones de la Goddard está el estudio del planeta Titán, que ofrece la tentadora posibilidad de que pueda existir vida entre sus islas azotadas por el viento y sus mares de un gélido color negro. Cuando la sonda de exploración Titan Alpha falla misteriosamente tras alcanzar la superficie de la luna, las tensiones que han permanecido enterradas durante tanto tiempo emergen entre los colonos, que deberán luchar por la supervivencia de la colonia, y por el destino de la raza humana.",
    "year": 2009,
    "authors": [
      "Ben Bova"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1465
  },
  {
    "title": "LUZ ROBADA",
    "isbn": "9788492431182",
    "synopsis": "Durante un cuarto de millón de años, una especie alienígena ha estado ocultando un secreto atroz y monstruoso. En el siglo XXV, los shoales son los únicos seres que poseen el secreto de los viajes superluminales, por lo que ostentan el control absoluto del comercio y las exploraciones de toda la galaxia. La ex piloto militar Dakota Merrick, que ha sido testigo de las atrocidades cometidas por los alienígenas, recibe el encargo de pilotar una nave de carga civil en una exploración espacial hacia un sistema solar en el que se halla el derrelicto de una nave espacial. En ella los pasajeros de Dakota esperan encontrar un dispositivo superluminal que, misteriosamente, no parece ser de origen shoal. Sin embargo, los shoales no están dispuestos a renunciar a su monopolio sobre una tecnología que adquirieron mediante un antiguo genocidio.",
    "year": 2008,
    "authors": [
      "Gary Gibson"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1469
  },
  {
    "title": "ANTIDOTO",
    "isbn": "9788445077481",
    "synopsis": "La plaga, un virus nanotecnológico que ataca a cualquier organismo de sangre caliente por debajo de los 3000 metros, ha asolado la Tierra. En las cumbres más altas del planeta, los supervivientes se aferran a la vida, a cualquier precio. La especialista en nanotecnología Ruth Goldman ha desarrollado una vacuna capaz de proteger a los supervivientes contra la plaga, pero el gobierno de los Estados Unidos se hace con el control de su descubrimiento. Decididos a compartir la cura, Ruth y Cam Najarro deberán afrontar que América se ha convertido en una tierra yerma y devastada. Juntos emprenderán un viaje durante el cual descubrirán lo mejor y lo peor de la naturaleza humana, ignorantes de que una amenaza aún mayor planea sobre sus cabezas.",
    "year": 2009,
    "authors": [
      "Jeff Carlson"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1475
  },
  {
    "title": "EL LIBRO DEL SOL NUEVO (CONTIENE: LA SOMBRA DEL TORTURADOR; LA GA RRA DEL CONCILIADRO; LA ESPADA DEL LICTOR; LA CIUDADELA DEL AUTARCA; LA URTH DEL SOL NUEVO)",
    "isbn": "9788445077153",
    "synopsis": "Toda la serie de El Libro del Sol Nuevo con este pack que incluye los cinco volúmenes. En un futuro tan distante que se parece al remoto pasado, el joven Severian estudia en la Ciudadela los misterios del gremio de los torturadotes. Pero con la llegada de Thecla, una hermosa e inteligente mujer, Severian desobedece las reglas, y la vida cambia para él.",
    "year": 2008,
    "authors": [
      "Gene Wolfe"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1476
  },
  {
    "title": "EL JUEGO DE ENDER (SAGA DE ENDER 4 / ENDER 1)",
    "isbn": "9788466639590",
    "synopsis": "La Tierra se ve amenazada por los insectores, una raza extraterrestre completamente ajena a los humanos, a los que pretende destruir. Para vencer a los insectores es necesario un nuevo tipo de genio militar, y por ello se ha permitido el nacimiento de Ender, quien en cierta forma constituye una anomalía viviente: es el tercer hijo de una pareja en un mundo que ha limitado estrictamente a dos el número de descendientes. El niño Ender deberá aprender todo lo relativo a la guerra en los videojuegos y en los peligrosos ensayos de batallas que realiza con sus compañeros. A la habilidad en el tratamiento de las emociones, ya característica de Orson Scott Card, se une en este libro el interés por el empleo de las simulaciones de ordenador y juegos de fantasía en la formación militar, estratégica y psicológica del protagonista.",
    "year": 2008,
    "authors": [
      "Orson Scott Card"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1477
  },
  {
    "title": "GREEN TOWN",
    "isbn": "9788445077115",
    "synopsis": "Green Town, la primera obra de Bradbury donde el tema es el pasado y no el futuro, es la novela de la felicidad. En la infancia de Douglas Spaulding, de doce años, Ray Douglas Bradbury descubre su propia infancia y la infancia del mundo americano. Toda la maravillosa poesía del incomparable Ray Bradbury está presente en esta historia.",
    "year": 2008,
    "authors": [
      "Ray Bradbury"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1485
  },
  {
    "title": "LA CHICA MECANICA",
    "isbn": "9788415831990",
    "synopsis": "La chica mecánicade Paolo Bacigalupi es la novela que ha renovado el género de la ciencia ficción de los últimos años.Bienvenidos al siglo XXIIAnderson Lake es el hombre de confianza de AgriGen en Tailandia, un reino cerrado a los extranjeros para proteger sus preciadas reservas ecológicas. Su empleo como director de una fábrica es en realidad una tapadera. Anderson peina los puestos callejeros de Bangkok en busca del botín más preciado para sus amos: los alimentos que la humanidad creía extinguidos. Entonces encuentra a Emiko.Emiko es una «chica mecánica», el último eslabón de la ingeniería genética. Como los demás neoseres a cuya raza pertenece, fue diseñada para servir.",
    "year": 2016,
    "authors": [
      "Paolo Bacigalupi"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1509
  },
  {
    "title": "LOS HIJOS DE GEA",
    "isbn": "9788483521793",
    "synopsis": "¿Qué ocurría si una mañana te levantases y descubrieses un extraño tatuaje sobre tu piel? ¿Si durante varias semanas, la misma pesadilla se repitiese noche tras noche? ¿Si de repente, tu cuerpo fuese capaz de moverse de una forma casi sobrenatural? Todo esto le sucede a Nicole, una joven de dieciséis años que ve su tranquila vida truncada al descubrir que ha sido elegida para, algún día, ser una Guardiana de la Orden de Alnilam, una de las diez casas que forman La Unión de Orión.Descubrirá una realidad paralela a la suya, donde dos organiza-ciones han llevado la enemistad surgida entre el gigante griego Orión y su asesino, Scorpius, durante más de dos mil años.\"Es difícil encontrar autoras con tanta imaginación que nos arras-tren y nos seduzcan como Natalia Corbillón en esta primera parte de su saga.",
    "year": 2009,
    "authors": [
      "Natalia Corbillon Gonzalez"
    ],
    "categories": [
      "Narrativa de ciencia ficción"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1518
  },
  {
    "title": "LA CITA",
    "isbn": "9788418451812",
    "synopsis": "«De modo que aquí la tienen. Una invitación a la sorpresa, a la admiración. Eso son, entre otras muchas cosas, los cuentos de doña Emilia Pardo Bazán. Si nunca la leyeron antes, les envidio. Están a punto de darse un auténtico festín de auténtica literatura.Damas, caballeros: pasen y lean».Así presenta Care Santos, en el prólogo de esta edición, el volumen que reúne diez cuentos de terror de Doña Emilia. Efectivamente, además de ensayos, libros de viajes, lírica, traducciones, su epistolario y, por supuesto, su más que famosa obra Los pazos de Ulloa, la escritora gallega fue también autora de una larga lista de historias cortas de terror que, como no podía ser de otra forma en alguien con el origen de Emilia Pardo Bazán, recopilan buena parte del imaginario fantástico gallego",
    "year": 2021,
    "authors": [
      "Emilia Pardo Bazan"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 15
  },
  {
    "title": "LA MALDICION DE HILL HOUSE",
    "isbn": "9788494836695",
    "synopsis": "Cuatro personajes llegan a un viejo y laberíntico caserón conocido como Hill House. Son el doctor Montague, un estudioso de lo oculto que busca pruebas de fenómenos psíquicos en casas encantadas, y tres personas a quienes el doctor ha reclutado para llevar a cabo un experimento. A pesar de las reticencias de su familia, Eleanor, una joven algo atormentada y de pasado infeliz, acabará formando parte de la singular comitiva. Los otros son Theodora, con quien Eleanor establece un fuerte vínculo inicial, y Luke, el heredero de la casa. Pronto todos deberán enfrentarse a situaciones que están más allá de su comprensión. Hill House parece estar preparándose para escoger a uno de ellos y hacerlo suyo para siempre. Llevada dos veces al cine e inspiración de una reciente serie televisiva, \"La maldición de Hill House\" es una de las novelas más famosas de Shirley Jackson y una de las principales obras de terror del siglo XX.",
    "year": 2019,
    "authors": [
      "Shirley Jackson"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 18
  },
  {
    "title": "NUESTRA PARTE DE NOCHE (PREMIO HERRALDE DE NOVELA 2019) (PREMIO NACIONAL DE LA CRITICA 2019)",
    "isbn": "9788433998859",
    "synopsis": "La herencia, el deseo de pervivir, la paternidad, el horror, lo íntimo y lo político. Una novela libre y osada, hechizante y genial.La herencia, el deseo de pervivir, la paternidad, el horror, lo íntimo y lo político. Una novela libre y osada, hechizante y genial.Un padre y un hijo atraviesan Argentina por carretera, desde Buenos Aires hacia las cataratas de Iguazú, en la frontera norte con Brasil. Son los años de la junta militar, hay controles de soldados armados y tensión en el ambiente. El hijo se llama Gaspar y el padre trata de protegerlo del destino que le ha sido asignado. La madre murió en circunstancias poco claras, en un accidente que acaso no lo fue.Como su padre, Gaspar está llamado a ser un médium en una sociedad secreta, la Orden, que contacta con la Oscuridad en busca de la vida eterna mediante atroces rituales.",
    "year": 2019,
    "authors": [
      "Mariana Enriquez"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 46
  },
  {
    "title": "LA CAJA DE BOTONES DE GWENDY",
    "isbn": "9788491292418",
    "synopsis": "Vuelve Stephen King con una impactante novela corta en un formato muy especial.La pequeña ciudad de Castle Rock, en Maine, ha sido testigo de algunos extraños sucesos, pero solo hay una historia que no se ha contado... hasta ahora.Existen tres vías para llegar a Castle View desde la ciudad de Castle Rock: por la carretera 117, por Pleasant Road y por las Escaleras de los Suicidios. Cada día del verano de 1974, Gwendy Peterson, de doce años de edad, toma el camino de las escaleras, que ascienden en zigzag por la ladera rocosa.Pero un día, al llegar a lo alto, mientras recupera el aliento con la cara roja y las manos apoyadas sobre las rodillas, un desconocido la llama. Allí, en un banco a la sombra, se sienta un hombre con una chaqueta negra y un pequeño sombrero. Llegará un día en el que Gwendy sufra pesadillas con ese sombrero.La crítica ha dicho.«Esta novela sobre el fin de la infancia mezcla un tono dulce con otro más amenazante...",
    "year": 2018,
    "authors": [
      "Stephen King"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 48
  },
  {
    "title": "HELLRAISER: EL CORAZON CONDENADO",
    "isbn": "9788494664762",
    "synopsis": "Una nueva edición y traducción del gran clásico de terror del siglo xx que ha inspirado las películas de culto de Hellraiser.En esta nueva versión al español de Hellraiser, que ahora publicamos con su título original, El corazón condenado, los lectores podrán acercarse a esta ya clásica novela de terror con una perspectiva nueva. Nominada como la mejor novela del año en el Reino Unido, treinta años después se ha convertido en una obra de culto tras la primera versión cinematográfica que se hizo de ella en 1987. Clive Barker aborda en sus páginas cuestiones cruciales como el amor y la desesperación, el deseo, la muerte y la sangre, mediante metáforas sugerentes, reflejando el hedonismo desenfrenado hasta límites trascendentes.",
    "year": 2017,
    "authors": [
      "Clive Barker"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 65
  },
  {
    "title": "EL EXORCISMO DE MI MEJOR AMIGA",
    "isbn": "9788445012482",
    "synopsis": "Dos jóvenes estudiantes de Secundaria, llamadas Abby y Gretchen, se tienen la una a la otra como mejores amigas desde los tiempos de la infancia. Pero en una noche de juerga en la que se bañan desnudas todo les sale espantosamente mal y Gretchen, a partir de entonces... cambia. Está siempre de mal humor. Irritable. Y empiezan a sucederse extraños incidentes en los que, invariablemente, Gretchen está implicada. Abby empieza a investigar y se adentra en un misterio sobrecogedor... Cuando la historia llegue a su momento culminante, el destino de Abby y Grechen girará en torno a una única pregunta: ¿La amistad entre ambas será lo bastante fuerte como para derrotar al Diablo?",
    "year": 2022,
    "authors": [
      "Grady Hendrix"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 69
  },
  {
    "title": "LA VUELTA DE TUERCA",
    "isbn": "9788477029298",
    "synopsis": "El genio de un narrador como Henry James, sin duda una de las cumbres de la literatura universal, la convierte en una obra maestra de obligada lectura, más allá de los géneros.La edición cuenta con ilustraciones de Francisco Torres Oliver.La víspera de Navidad, unos amigos se reúnen junto al fuego dispuestos a disfrutar de una velada escuchando narraciones de sucesos sobrenaturales. Cuando el protagonista de una historia de fantasmas es un niño, argumenta uno de los reunidos, esto añade como una vuelta de tuerca a la impresión que produce en el oyente. ¿Y si fueran dos niños?.A continuación, propone a los presentes la lectura de una historia que le envió por escrito la que fuera institutriz de su hermana, ya fallecida, y que aseguraba haber vivido en carne propia.La narración en primera persona da comienzo cuando la institutriz responde a un anuncio para ocuparse de dos niños huérfanos.",
    "year": 2022,
    "authors": [
      "Henry James"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 70
  },
  {
    "title": "CUERNOS",
    "isbn": "9788418440380",
    "synopsis": "¿Qué harías si un día te despertaras convertido en el diablo?La vida de Ig Perrish es un infierno desde que su novia Merrin fuera asesinada un año atrás, en un episodio que tendió sobre él un manto de sospechas que nunca pudo sacudirse.Una mañana, tras una fuerte borrachera, amanece con unos cuernos creciéndole en la frente. Pronto descubre que ejercen un extraño efecto en los demás: les hacen revelarle sus secretos más oscuros. Así, Ig se entera de que todo el pueblo, incluso sus padres, cree que fue él quien mató a Merrin.Y pocoa poco, pasado el desconcierto inicial, Ig aprenderá a sacar partido de ser el mismísimo diablo.Una extravagante, original e imaginativa novela donde todo es, aparentemente, inexplicable.«Una historia llena de matices. El fuego y el azufre pocas veces han tenido tan buen aspecto».",
    "year": 2022,
    "authors": [
      "Joe Hill"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 85
  },
  {
    "title": "LOS ARCHIVOS DEL DOCTOR HESSELIUS",
    "isbn": "9788477029328",
    "synopsis": "Joseph Sheridan Le Fanu nació en Dublín en 1814 y recibió una esmerada educación de su padre, clérigodescendiente de hugonotes, que lo envió al prestigioso Trinity Collegede Dublín para estudiar leyes. Pero Le Fanú nunca ejercióla abogacía, y al terminar sus estudios en 1839 cambió elestrado por los periódicos. Escribió buen número depoemas, baladas y relatos cortos que publicó en laDublinUniversity Magazine, hasta que en 1861 se convirtió en su directory propietario. Tras la muerte de su esposa en 1858, Le Fanu abandonótoda vida social y se transformó en un escritor de hábitosnoctámbulos apasionado por las ciencias ocultas, al que los dublinesesconocían como «El Príncipe Invisible». Sus novelas e historiasde fantasmas lo han convertido en un gran maestro del terror sobrenaturaly de la «ghost story» victoriana.",
    "year": 2022,
    "authors": [
      "Joseph Sheridan Le Fanu"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 87
  },
  {
    "title": "LA CIUDAD DE LOS ESPEJOS",
    "isbn": "9788492915941",
    "synopsis": "Por fin, el esperado final de \"El Pasaje\", la trilogía vampírica de Justin Cronin que ha conquistado a millones de lectores de todo el mundo. Una magistral saga sobre la caída de la civilización y la desesperada lucha de la humanidad por sobrevivir.La cadena FOX producirá una serie televisiva adaptando la serie.El mundo tal como lo conocíamos ha desaparecido.¿Qué clase de mundo surgirá en su lugar?Los Doce han sido destruidos y el aterrador imperio de las tinieblas, que desde hace un siglo azota el mundo, ha llegado a su fin. Los supervivientes empiezan a cruzar las murallas, decididos a construir una nueva sociedad. y listos para soñar con un futuro más esperanzador.Sin embargo, muy lejos de allí, en una metrópolis muerta, alguien aguarda: Zero. El Primero. Padre de los Doce. El horror que devastó su vida humana todavía lo atormenta y el rencor que su transformación engendró en su corazón sigue vivo.",
    "year": 2017,
    "authors": [
      "Justin Cronin"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 89
  },
  {
    "title": "LOS EVANGELIOS ESCARLATA",
    "isbn": "9788412382631",
    "synopsis": "EnLos evangelios escarlata,Clive Barker traslada al lector al más remoto rincón del infierno (la isla llamada Yapora Yariziac), donde dos de sus personajes más icónicos Harry DAmour (detective de lo oculto neoyorquino) y Pinhead (tentador de la Orden de la Incisión) se enfrentarán en una lucha a muerte en la que se decidirá el destino del infierno, la Tierra y el cielo.Tanto los devotos de Barker como los fans deHellraiserhallarán en esta novela ansiosamente esperada durante años cuanto habían soñado y mucho más: acción y sangre a raudales, además del humor negro y las truculencias del Barker más salvaje e iconoclasta.Ni los fanáticos ni los recién llegados se sentirán decepcionados con la historia épica y visionaria, aterradora y brillantemente compleja narrada enLos evangelios escarlata.El horror en estado puro de Barker hará que tus peores pesadillas parezcan cuentos infantiles.Como dice el mismo Pinhead: «He aquí mis evangelios",
    "year": 2021,
    "authors": [
      "Clive Barker"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 105
  },
  {
    "title": "LA IRA DE N KAI",
    "isbn": "9788445008027",
    "synopsis": "La primera de una nueva colección de novelas de espeluznantes aventuras basada en el popular Arkham Horror: una ladrona internacional de artefactos esotéricos se topa con un culto de pesadilla en la Nueva Inglaterra de los años veinte La condesa Alessandra Zorzi, una aventurera y ladrona cosmopolita, llega a Arkham en busca de un cuerpo recién exhumado en Oklahoma, de curioso origen y peculiares características. Pero antes de que pueda hacerse con él, otro grupo se le adelanta. Durante un tiroteo en el Museo Miskatonic, la condesa establece contacto visual con el cadáver, lo que desencadena una serie de descubrimientos que superan con creces sus experiencias más salvajes. Ahora, atrapada entre su misterioso cliente, la policía y una sociedad de expertos necrófagos, sigue las pistas de la momia resurrecta, así como del horror alienígena que la acompaña. Esta novela se inspira en el ?horror cósmico? de H.",
    "year": 2021,
    "authors": [
      "Josh Reynolds"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 106
  },
  {
    "title": "CUENTOS COMPLETOS",
    "isbn": "9788417477684",
    "synopsis": "El autor norteamericano Edgar Allan Poe (1809-1849) ocupa un lugar relevante en el panteón de los escritores más admirados, imitados y estudiados de la literatura universal. Considerado por muchos como un precursor del cuento corto y de terror como género literario, Edgar Allan Poe escribió también poesía, ensayos y crítica literaria. Aunque indudablemente fascinado con lo macabro y con un especial talento para ello, Poe también exploró diversos temas y tonos en su obra, con relatos detectivescos (de los cuales también es considerado pionero), humorísticos, históricos y hasta crónicas periodísticas. Su obra ha inspirado innumerables homenajes e influenciado el estilo de autores como H. P. Lovecraft y Arthur Conan Doyle. Con una vida marcada por la tragedia Poe logró dejar una huella indeleble en la historia literaria de su país y del mundo, como un maestro de la naturaleza humana y de todos sus matices.",
    "year": 2019,
    "authors": [
      "Edgar Allan Poe"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 115
  },
  {
    "title": "SIEMPRE HEMOS VIVIDO EN EL CASTILLO",
    "isbn": "9788494534867",
    "synopsis": "Merricat lleva una vida solitaria en una gran casa apartada del pueblo. Allí pasa las horas recluida con su bella hermana mayor y su anciano tío Julián. En el hogar de los Blackwood los días discurrían apacibles si no fuera porque los otros miembros de la familia murieron envenenados allí mismo, en el comedor, seis años atrás.",
    "year": 2017,
    "authors": [
      "Shirley Jackson"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 118
  },
  {
    "title": "LOS PELIGROS DE FUMAR EN LA CAMA",
    "isbn": "9788433998248",
    "synopsis": "Una niña desentierra en el jardín unos huesos que resultan no ser de un animal; la bucólica escena veraniega de unas chicas que se bañan en un paraje natural acaba convertida en un infierno de celos de inquietantes consecuencias; un mendigo despreciado siembra la desgracia en un barrio pudiente; Barcelona se transforma en un escenario perturbador, marcado por la culpa y del que es imposible escapar; una presencia fantasmal busca un sacrificio en un balneario; una chica siente una atracción fetichista por los corazones enfermos; un rockero fallecido de un modo atroz recibe un homenaje de sus fans que va más allá de lo imaginable; un chico que filma clandestinamente a parejas haciendo el amor y a mujeres con tacones altos caminando por las calles recibe una propuesta que le cambiará la vida.En los doce soberbios cuentos que componen este volumen Mariana Enriquez despliega todo un repertorio de recursos del relato clásico de terror: aparic",
    "year": 2017,
    "authors": [
      "Mariana Enriquez"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 119
  },
  {
    "title": "UN VERANO TENEBROSO",
    "isbn": "9788466664738",
    "synopsis": "El gran clásico de terror de Dan Simmons que te pondrá los pelos de punta.Verano de 1960. En el pueblecito de Elm Haven, Illinois, cinco pre-adolescentes de doce años pasan sus días bajo atardeceres en bicicleta, juegos y descubrimientos propios de una pacífica infancia en un lugar idílico. Sin embargo, tras la desaparición de un compañero de clase, su afán de aventura los llevará a averiguar mucho más de lo que esperaban: un mundo paralelo en el que la realidad y la fantasía apenas se distinguen.El inesperado repique de una extraña campana europea en medio de la noche marcará el fin de los días tranquilos. Ahora, desde las profundidades de Old Central School, el mal acecha.",
    "year": 2019,
    "authors": [
      "Dan Simmons"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 129
  },
  {
    "title": "GOTICO",
    "isbn": "9788445009819",
    "synopsis": "Una novela terroríficamente brillante.Tras recibir una extraña carta de su prima recién casada, Noemí Taboada se dirige a High Place, una casa en el campo en México, sin saber qué encontrará allí. Noemí no parece tener dotes de salvadora: es glamurosa, más acostumbrada a asistir a cócteles que a las tareas de detective. Pero también es fuerte, inteligente y no tiene miedo: ni del nuevo marido de su prima, un inglés amenazante y seductor; ni de su padre, el antiguo patriarca que parece fascinado por Noemí; ni de la casa, que empieza a invadir los sueños de Noemí con visiones de sangre y fatalidad.El único amigo que Noemí encontrará es el hijo menor de la familia, quien también da la impresión de estar tapando secretos oscuros. Porque hay muchos secretos escondidos en las pareces de High Place, como descubrirá Noemí cuando empiece a desenterrar historias de violencia y locura.",
    "year": 2021,
    "authors": [
      "Silvia Moreno-Garcia"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 134
  },
  {
    "title": "A TUMBA ABIERTA",
    "isbn": "9788417834968",
    "synopsis": "En estos magistrales relatos (dos coescritos con Stephen King), Joe Hill disecciona conflictos muy humanos en escenarios fantasmagóricos. Una puerta que da a un mundo prodigioso y lleno de maravillas se torna sangrienta cuando la atraviesa un grupo de cazadores. Dos hermanos se adentran en un laberíntico campo de hierba alta para ayudar a un niño que pide auxilio entre la maleza. Un camionero se ve envuelto en una sofocante persecución por el desierto de Nevada. Cuatro adolescentes suben a un antiguo carrusel donde cada vuelta tiene consecuencias espeluznantes. Un bibliotecario se pone al volante para llevar lecturas a los muertos. Dos amigos descubren el cadáver de un plesiosaurio en la orilla de un lago, un hallazgo que les fuerza a enfrentarse a la idea de su propia mortalidad... y a otros horrores que acechan en las profundidades acuáticas.",
    "year": 2021,
    "authors": [
      "Joe Hill"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 136
  },
  {
    "title": "LOS SERES HUECOS (LAS CINTAS DE BLACKWOOD VOL. 1)",
    "isbn": "9788413620787",
    "synopsis": "Un crimen inexplicable, una agente del FBI novata y un héroe extraordinario La vida de Odessa Hardwicke descarrila cuando se ve obligada a disparar a su compañero, un agente federal que pierde el control de forma inexplicable durante la captura de un violento asesino. El disparo, en defensa propia, conmociona a la joven agente, pero lo que más inquieta a Odessa es el ente espectral que le ha parecido ver desprenderse del cuerpo de su compañero fallecido. Hardwicke, que duda de su cordura y de su futuro en el FBI, acepta encargarse de recoger las pertenencias de un agente jubilado en la oficina de Nueva York. Lo que encuentra allí la pondrá sobre la pista de una figura misteriosa: Hugo Blackwood, un hombre tremendamente rico que asegura llevar siglos vivo y que o está loco de remate o es la mejor y única defensa de la humanidad frente a un mal indescriptible.",
    "year": 2020,
    "authors": [
      "Guillermo Del Toro"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 138
  },
  {
    "title": "IT",
    "isbn": "9788466347921",
    "synopsis": "¿Quien o que mutila y mata a los niños de un pequeño pueblo norteamericano?¿Por que llega cíclicamente el horror a Derry en forma de un payaso siniestro que va sembrando la destrucción a su paso? Esto es lo que se proponen averiguar los protagonistas de esta novela. Tras veintisiete años de tranquilidad y lejanía, una antigua promesa infantil les hace volver al lugar en el que vivieron su infancia y juventud como una terrible pesadilla. Regresan a Derry para enfrentarse con su pasado y enterrar definitivamente la amenaza que los amargó durante su niñez. Saben que pueden morir, pero son conscientes de que no conocerán la paz hasta que aquella cosa sea destruida para siempre. It es una de las novelas más ambiciosas de Stephen King, con la que ha logrado perfeccionar de un modo muy personal las claves del genero de terror. La crítica ha dicho.\"Insuperable.\"La Vanguardia",
    "year": 2019,
    "authors": [
      "Stephen King"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 140
  },
  {
    "title": "VAMPIRO",
    "isbn": "9788477028796",
    "synopsis": "Tras la catastrófica derrota alemana en la Primera Guerra Mundial, los países de habla germana vivieron un renacimiento cultural: Freud en Viena, Kafka en Praga, y el cine de Murnau y Fritz Lang. En este caldo de cultivo surge también una generación de escritores, Gustav Meyrink, H.H. Ewers y Karl Hans Strobl, que reivindican la tradición del «romanticismo negro» de Hoffmann, Tieck o Poe.Hanns Heinz Ewers, autor de la inmortal «Mandrágora» (Gótica-9), fue un dandi y un viajero impenitente que recorrió todo el globo.",
    "year": 2018,
    "authors": [
      "Hanns Heinz Ewers"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 146
  },
  {
    "title": "DRACULA (CLASICOS ILUSTRADOS)",
    "isbn": "9788415618836",
    "synopsis": "Las de Bram Stoker y Jonathan Harker fueron vidas paralelas. Stoker era el secretario particular de Henry Irving, un reputado actor shakespeariano y propietario del Lyceum Theatre de Londres; Harker, el del enigmático conde Drácula, quien lo convocó a su castillo de Transilvania para negociar la adquisición de una mansión en Londres. No es casual que el personaje de Drácula se inspire en las facciones e idiosincrasia de Irving, ni que Stoker hiciese una lectura pública en el Lyceum Theatre días antes de su edición.Drácula es la novela vampírica por antonomasia. En ella se concitan los grandes ejes temáticos del subgénero: la lucha entre el bien y el mal y la sexualidad del vampiro, con una estética victoriana y un despliegue estilístico abrumador. Todo ello la convierte en un clásico incontestable e imperecedero.",
    "year": 2018,
    "authors": [
      "Bram Stoker"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 149
  },
  {
    "title": "HEX",
    "isbn": "9788417834524",
    "synopsis": "Bienvenido a Black Spring, una población pintoresca con un macabro secreto: una mujer recorre las calles con la boca y los ojos cosidos, entra en los hogares y espía a la gente mientras duerme. La llaman la Bruja de Black Rock.Los vecinos se han acostumbrado tanto a su presencia que a veces se les olvida lo que ocurrirá si algún día abre los ojos. Para protegerse de curiosos, los fundadores de Black Spring han instalado equipos de vigilancia con los que mantienen la zona en cuarentena. Hasta que unos adolescentes, hartos de su aislamiento, deciden saltarse las normas y convertir la maldición en una experiencia viral.Nadie se imagina la siniestra pesadilla que entonces los aguarda.HEX es el gran éxito editorial de terror neerlandés que ha arrasado en ventas tanto en Europa como Estados Unidos. La Warner Bros. ha comprado sus derechos televisivos y cinematográficos.",
    "year": 2020,
    "authors": [
      "Thomas Olde Heuvelt"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 152
  },
  {
    "title": "SLEEPY HOLLOW. LA LEYENDA DEL JINETE SIN CABEZA (ED. GIGANTE ILUSTRADA)",
    "isbn": "9788419343048",
    "synopsis": "En el seno de una de esas colosales ensenadas que se adentran en la orilla oriental del Hudson, en esa amplia extensión del río denominada por los antiguos navegantes holandeses el Tappan Zee, y donde siempre acortaban prudentemente las velas e imploraban la protección de San Nicolás cuando cruzaban, se encuentran un pequeño pueblo mercante y su puerto, que algunos llaman Greensburgh, pero que se conoce más comúnmente con el nombre de Tarry3 Town. Este nombre fue dado, según se cuenta, en tiempos pasados, por las buenas mujeres del pueblo vecina, por la muy establecida costumbre de sus maridos de frecuentar su taberna los días de mercado. Sea como fuere, no doy fe del hecho, sino que me limito a mencionarlo, en aras de la precisión y la autenticidad.",
    "year": 2022,
    "authors": [
      "Washington Irving"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 175
  },
  {
    "title": "GRUPO DE APOYO PARA FINAL GIRLS",
    "isbn": "9788445013120",
    "synopsis": "En las películas de miedo, las Final Girls son las que han quedado con vida cuando empiezan a pasar los títulos de créditos. Han sobrevivido a la peor noche de su vida, sí, pero? ¿qué sucede luego? Lynnette Tarkington es una Final Girl, una de esas que sobrevivió a una masacre. Durante más de una década, ha estado reuniéndose con otras cinco Final Girls y con su terapeuta en un grupo de apoyo secreto para mujeres que han sobrevivido a situaciones increíbles, trabajando todas ellas para recuperar su vida. Entonces, un día, una de ellas parece que llegue tarde a la reunión? hasta que los peores miedos de las demás se hacen realidad: al parecer, alguien conoce la existencia del grupo y está decidido a asesinar a todas sus integrantes, una a una.",
    "year": 2022,
    "authors": [
      "Grady Hendrix"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 176
  },
  {
    "title": "LA ULTIMA MISION DE GWENDY (TRILOGIA LA CAJA DE BOTONES DE GWENDY 3)",
    "isbn": "9788491296331",
    "synopsis": "Stephen King y Richard Chizmar se unen una vez más para traernos el increíble desenlace de la historia que comenzaron conLa caja de botones de Gwendy.Cuando tenía doce años, Gwendy Peterson conoció a Richard Farris, un tipo misterioso que le pidió que cuidara de una extraña caja de botones.Ahora, Gwendy es una afamada novelista y su carrera política está empezando a despegar. Parece que lo tiene todo a su alcance, pero entonces el insólito objeto vuelve a su vida. Las fuerzas del mal se han apoderado por completo de la caja de botones y ahora recae sobre Gwendy la responsabilidad de alejarlas de ella. ¿Su última misión? Salvar al mundo. Y puede que a todos los mundos.La crítica ha dicho:«La trilogía de Gwendy, de Stephen King y Richard Chizmar, llega a su fin... Las últimas páginas son, a la vez, satisfactorias y profundamente emotivas.",
    "year": 2022,
    "authors": [
      "Stephen King"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 189
  },
  {
    "title": "NARRATIVA COMPLETA (VOL. 2)",
    "isbn": "9788477025870",
    "synopsis": "Howard Phillips Lovecraft (1890-1937) fue un ave nocturna y un cazador de sueños. Nació en Providence (Nueva Inglaterra), donde vivió la mayor parte de su corta vida, que dedicó a contemplar las estrellas, leer con avidez cuanto caía en sus manos y, sobre todo, escribir (poesía, ensayo, relatos y una ingente correspondencia). Al refugiarse en su hermético mundo onírico, Lovecraft se embarcó en un viaje sin retorno hacia una nueva dimensión: el miedo cósmico, el «terror de los espacios infinitos», que estremecía a Pascal. Lo que caracteriza la ficción lovecraftiana es la utilización de elementos de la tradición gótica reinterpretados en términos científicos. Sus relatos expresan la soledad y la pequeñez de la condición humana en un universo infinito y amoral, azaroso y hostil, carente de significado y angustiosamente ajeno a nuestras preocupaciones y cavilaciones.",
    "year": 2010,
    "authors": [
      "H.p. Lovecraft"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 200
  },
  {
    "title": "ENTREMEDIAS",
    "isbn": "9788412281361",
    "synopsis": "Hilton James tuvo una infancia difícil; un día llegó del colegio y encontró a su abuela Nana muerta en el suelo, fría como la piedra; corrió a buscar ayuda, y cuando volvió se encontró a Nana viva, tranquila. A partir de ese día, Nana sufría pesadillas y Hilton se sentía cada vez más intranquilo a su lado, como si ya no fuera la misma. Meses después Nana murió al rescatarlo de morir ahogado en una playa de Miami.El pequeño Hilton fue a vivir con unos parientes, creció, fue a la universidad y allí conoció a la flamante Dede, con quien finalmente se casó y formó una familia. Pero su felicidad está marcada por unos sueños extraños y recurrentes, más violentos y alarmantes conforme se acerca su cumpleaños.",
    "year": 2022,
    "authors": [
      "Tananarive Due"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 211
  },
  {
    "title": "EL TIO SILAS",
    "isbn": "9788477029281",
    "synopsis": "Destacado representante de la fructífera escuela irlandesa de literatura fantástica, Joseph Sheridan Le Fanu nació en Dublín en 1814 y estudió en el elitista Trinity College al igual que otros autores ilustres como Charles Maturin, creador del inmortal Melmoth el errabundo , o Bram Stoker, padre del mito de Drácula. Le Fanu repartió su actividad entre el periodismo llegó a dirigir el Dublin University Magazine y la creación literaria.Entre 1845 y 1873 publicó catorce novelas históricas y de misterio, y un buen número de relatos fantásticos, entre los que destaca Carmillaö, probablemente la más lograda historia de vampiros jamás escrita.",
    "year": 2022,
    "authors": [
      "Joseph Sheridan Le Fanu"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 212
  },
  {
    "title": "LA PEQUEÑA EVE",
    "isbn": "9788413627892",
    "synopsis": "Premio Shirley Jackson y premio August Derleth a la mejor novela de horror de los British Fantasy Awards 2019.«¿Dónde está Evelyn? Ah, ya me acuerdo. Nos quitó los ojos.»\"Un maravilloso cuento gótico.\" Sarah PinboroughPremio Shirley Jackson y premio August Derleth a la mejor novela de horror de los British Fantasy Awards 2019.«¿Dónde está Evelyn? Ah, ya me acuerdo. Nos quitó los ojos.»Día de año nuevo, 1921. Siete cuerpos mutilados aparecen en un antiguo círculo de piedras en Altnaharra, una remota isla escocesa. Son \"los Niños\", miembros de un culto gobernado por una sádica figura a quien llaman \"el tío\". La única superviviente, Dinah, afirma que los ha asesinado Eve, que se habría ahogado al intentar escapar.",
    "year": 2022,
    "authors": [
      "Catriona Ward"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 216
  },
  {
    "title": "LA LLAMADA DE CTHULHU",
    "isbn": "9788445006467",
    "synopsis": "La llamada de Cthulhu inaugura la nueva colección Ilustrados Minotauro, adaptaciones derelatos clásicos en formato de álbum ilustrado.Con esta novela, Lovecraft escribe en los años 20 del pasado siglo una de las historias más famosas de la literatura fantástica americana. Cthulhu, el Gran Antiguo que sueña y espera en el fondo de los negros abismos oceánicos, se convertirá por sí solo en el símbolo de todo el universo que crea el autor de Providence. Fascinado desde siempre por esta obra repleta de criaturas que se ocultan en los rincones más oscuros y de Antiguos titánicos cuya mera visión basta para precipitar a cualquiera a la locura, François Baranger, ilustrador reconocido en el mundo por su talento para la ilustración de concepto para el cine y los videojuegos, se ha puesto manos a la obra «ciclópea» de expresar en imágenes los relatos principales de H.P. Lovecraft.",
    "year": 2019,
    "authors": [
      "H.p. Lovecraft"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 225
  },
  {
    "title": "EL HAMBRE",
    "isbn": "9788491814733",
    "synopsis": "\"Muy, muy turbadora y adictiva. No es recomendable leerla después del anochecer\". Stephen KingEn mayo de 1846 partió una caravana de pioneros de Missouri hacia California. Tomaron una nueva ruta que cruzaba el desierto del Gran Lago Salado y ese invierno se encontraron atrapados en Sierra Nevada debido a las dificultades del terreno y a una serie de accidentes. Cuando los pudieron rescatar en febrero del año siguiente muchos pioneros habían muerto y se supone que los que quedaban vivos habían logrado sobrevivir gracias al canibalismo. Hasta aquí, la historia. Alma Katsu toma este legendario episodio del Oeste americano y lo recrea dándole un giro especial. La caravana no solo se enfrenta al frío, a la pérdida del ganado, que muere sin poderse mover en la nieve, a la falta de provisiones, a las rencillas entre sus miembros... sino que el bosque se empieza a llenar de criaturas que les acechan.",
    "year": 2019,
    "authors": [
      "Alma Katsu"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 227
  },
  {
    "title": "TIEMPO EXTRAÑO",
    "isbn": "9788416858705",
    "synopsis": "En Tiempo extraño, \"uno de los mejores escritores norteamericanos de terror\" (Time), que va \"más allá de los convencionalismos del género hasta un nuevo extremo\" (The New York Times), expone con sutileza la oscuridad que se oculta bajo la superficie de la vida cotidiana a través de cuatro espeluznantes e imaginativas novelas cortas.\"Instantánea\" es la perturbadora historia de un adolescente de Silicon Valley que se descubre amenazado por el dueño de una cámara Polaroid capaz de borrar los recuerdos con cada foto que hace. \"En el aire\" nos lleva por todo lo alto junto a un chico que, en su primer salto en paracaídas, aterriza como náufrago en una nube imposiblemente sólida. \"Lluvia\" transcurre en Boulder, Colorado, en un día normal... hasta que estalla la tormenta: miles de agujas caen del cielo y perforan todo lo que se encuentra debajo. Y \"cuando la lluvia cayó, casi todo el mundo estaba fuera\".",
    "year": 2018,
    "authors": [
      "Joe Hill"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 236
  },
  {
    "title": "(PE) OBRAS SELECTAS H.P. LOVECRAFT",
    "isbn": "9788497944373",
    "synopsis": "Algo mágico tenia este escritor, cuando, a pesar de que su literatura no le daba para vivir, levanto ese velo de admiración a su alrededor. El francés Michel Houellebeqc escribió textualmente: “Siempre quiso verse como un gentilhombre de provincias, que cultiva la literatura como una de las bellas artes, para su propio deleite y el de algunos amigos, sin preocuparse por los gustos del gran público, los temas de moda o cualquier otra cosa por el estilo. Un personaje semejante ya no tiene cabida en nuestras sociedades, en una época de mercantilismo enloquecido, es reconfortante encontrar a alguien que se niega con tal obstinación a “venderse”",
    "year": 2018,
    "authors": [
      "H.p. Lovecraft"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 239
  },
  {
    "title": "A CIEGAS",
    "isbn": "9788445005910",
    "synopsis": "El libro que inspiró la película de Netflix BIRD BOX.NO ABRAS LOS OJOS. Hay algo ahí fuera. Algo espantoso, que hace que la gente enloquezca y se suicide ante su sola visión. Nadie sabe qué es ni de dónde viene.Cinco años después de que diera comienzo la pesadilla, los pocos supervivientes que quedan viven refugiados en el interior de casas y edificios, protegidos por puertas cerradas y ventanas con las cortinas echadas. Malorie, que ha conseguido sobrevivir en una casa abandonada junto a sus dos hijos, decide abandonar la seguridad de su refugio para emprender un viaje por el río hacia un lugar mejor. En esta peligrosa odisea a ciegas, Malorie sólo podrá confiar en su instinto y en el entrenado oído de los niños, que no tardarán en descubrir que algo los sigue. Pero, ¿qué es?",
    "year": 2018,
    "authors": [
      "Josh Malerman"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 240
  },
  {
    "title": "NIDO DE PESADILLAS",
    "isbn": "9788494354618",
    "synopsis": "\"Atrévete a entrar en el Nido de Pesadillas de Lisa Tuttle, trece relatos terroríficos de una de las más destacadas autoras de terror y fantasía de todos los tiempos.Nido de bichos · Hamburguesa de carne de muñeca · Bienes compartidos · Volando a Bizancio · Recorriendo el laberinto · El señor de los caballos · La otra madre · Necesidad · La memoria de la madera · Cuando te necesita un amigo · La extraña · Sun City · El nido\"",
    "year": 2015,
    "authors": [
      "Lisa Tuttle"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 249
  },
  {
    "title": "LAS MANOS DE ORLAC",
    "isbn": "9788418708510",
    "synopsis": "Durante su viaje de regreso a París, el mundialmente reconocido pianista Stéphen Orlac sufre un terrible accidente ferroviario en el que pierde su don más preciado: las dos manos. Será el controvertido doctor Cerral ;héroe de los pioneros trasplantes en heridos de la Primera Guerra Mundial; el encargado de practicar una arriesgada cirugía en la que se le injertarán al virtuoso músico las manos de un hombre recién fallecido.",
    "year": 2021,
    "authors": [
      "Maurice Renard"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 267
  },
  {
    "title": "LA PESCA DEL DIABLO Y OTROS RELATOS EXTRAÑOS",
    "isbn": "9788418320439",
    "synopsis": "Nuevo volumen de la colección de relatos de fantasmas en Diábolo Ediciones! Éste, sin duda, juzgó oportuno el instante para sus inicuos planes; porque avanzó paso a paso sin hacer ruido cayendo de improviso sobre la mujer, cuyo cuello sujetó con ambas manos haciendo que cayera a sus pies, exhalando un débil gemido.Deslió de su cuello la destrozada bufanda que introdujo bárbaramente casi toda en la rasgada boca de la víctima, cuyos ojos empezaban a inyectarse de sangre; en seguida la aplicó un fuerte puñetazo sobre el cráneo.",
    "year": 2021,
    "authors": [
      "Pedro Escamilla"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 280
  },
  {
    "title": "HORRORSTOR",
    "isbn": "9788417615086",
    "synopsis": "Ohio. Cada mañana, los empleados se encuentran destrozados los armarios Kjerring, tiradas por el suelo las lámparas Brooka, y extrañas manchas en los sofás Liripip. Para desvelar este misterio, cinco jóvenes empleados se ofrecen como voluntarios para un largo turno de noche, en el que afrontarán horrores que desafían la imaginación. Una tradicional historia de casas encantadas en un entorno contemporáneo (y repleto de horrores propios de nuestra época).Horrorstor es una novela que viene convenientemente presentada en forma de catálogo completo, con ilustraciones para montar los muebles y otros accesorios más siniestros. ¡Te prometemos que no has visto nada igual!¡Bienvenidos a Orsk!La tienda sueca de muebles más famosa del mundo esconde un secreto terrorífico.¿Sonidos en la oscuridad? ¿muebles que parecen potros de tortura? ¿laberínticos pasillos? ¿ofertas de morirse? ¡No hay mejor plan para un sábado por la noche que ir a Orsk!",
    "year": 2022,
    "authors": [
      "Grady Hendrix"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 287
  },
  {
    "title": "EL COLOR QUE CAYO DEL CIELO",
    "isbn": "9788412229356",
    "synopsis": "«No podía regresar a aquel caos difuso de bosque antiguo y colinas, o en-frentar otra vez el páramo calcinado gris donde el pozo de agua negra boste-zaba profundo junto a los ladrillos y las piedras derruidas.» Un meteorito atraviesa millones de kilómetros y se incrusta en las colinas de Arkham. Al romperse, una tonalidad supranatural, nunca vista, emerge e infecta las napas de agua. Desde el elemento vital, pasa a los animales y a los seres humanos, a quienes trastorna y enloquece. La amenaza cobra un carácter impenetrable y escapar se torna imposible. Las ilustraciones del dibujante Salvador Sanz, de marcado estilo hiperrea-lista, rubrican esta novela corta de terror metafísico ?traducida por Elvio Gandolfo? a través de un poderoso manejo de contrastes y de la irrupción de la luz.",
    "year": 2021,
    "authors": [
      "H.p. Lovecraft"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 292
  },
  {
    "title": "LA SEMILLA DE CTHULHU",
    "isbn": "9788413626239",
    "synopsis": "Discípulo, amigo y estrecho colaborador de H. P. Lovecraft, August Derleth desempeñó un papel decisivo en la conformación definitiva de los llamados \"mitos de Cthulhu\", que remontan al lector a un universo onírico en que se libra la eterna lucha entre las fuerzas del bien y del mal bajo la constante amenaza de un horror cósmico y primordial presto a traspasar las barreras del tiempo.La semilla de Cthulhu reúne por primera vez en español los tres libros que Derleth escribió bajo esta inspiración.Discípulo, amigo y estrecho colaborador de H. P.",
    "year": 2022,
    "authors": [
      "August Derleth"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 299
  },
  {
    "title": "CUENTOS",
    "isbn": "9788491875598",
    "synopsis": "Casi siempre ignorado por sus contemporáneos, el genio atormentado de Edgar Allan Poe no tardó en ser reconoícido tras su muerte por autores de la talla de Baudelaire, Dostoievski, Jules Verne o Mallarme. En la actualidad, sus cuentos son considerados como perfectas obras pioneras del terror psicológico y tambien de otros generos como la narración detectivesca o la ciencia ficción. Además de recopilar todos sus relatos breves, este volumen se abre con una completa introducción al universo teneíbroso y oscuro de Poe, y presenta la celebre traducción de otro maestro del cuento: Julio Cortázar.",
    "year": 2019,
    "authors": [
      "Edgar Allan Poe"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 305
  },
  {
    "title": "EL REY DE AMARILLO",
    "isbn": "9788477027119",
    "synopsis": "Robert William Chambers (1865-1933) nació en Brooklyn en una familia de terratenientes de origen escocés. Estudió en el New York Art Students League y en 1886 se trasladó a París, donde convivió con la bohemia artística del fin de siglo.Cuando Chambers regresa a Nueva York, su vocación de ilustrador cede a su pasión por contar historias y publica un primer libro, «In the Quarter» (1894), sobre sus experiencias en París. Le seguirá un año después una colección de relatos, «El Rey de Amarillo», que le convierte en un maestro indiscutible del moderno cuento de terror, capaz de aportar una visión del mal, el horror y lo sobrenatural, alejada por completo del monstruo y el fantasma gótico clásico.En «El Rey de Amarillo.",
    "year": 2011,
    "authors": [
      "Robert Chambers"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 314
  },
  {
    "title": "LEVEIL DE MADAME ISABEL",
    "isbn": "9788494804205",
    "synopsis": "Toda historia gana encanto cuando encierra una leyenda misteriosa. Algunos de vosotros os preguntareis si los fantasmas y los vampiros existen. Decidí inspirarme en un personaje que me llamó mucho la atención, para mí, una súper heroína de su tiempo: Lady Isabela Shaw. Según cuenta la leyenda, su marido, James Shaw, la encerró sin alimentarla en una de las torres del castillo de Ballygally (situado a unos veinte kilómetros al norte de Belfast) por no darle un heredero varón.",
    "year": 2017,
    "authors": [
      "Yolanda Felice"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1209
  },
  {
    "title": "BATALLA POR CHICAGO",
    "isbn": "9788494102097",
    "synopsis": "Chicago, años 30. La época de la ley seca, de las bandas organizadas y de algo más. Una serie de extraños asesinatos asolan Chicago. Las víctimas aparecen horriblemente mutiladas y desangradas mediante terribles mordeduras en el cuello. No son los únicos muertos con los que la ciudad debe lidiar. Brutales crímenes en los que los cadáveres son descubiertos sin piel ponen en alerta al periodista Samuel Parker, mientras la investigadora Jessica Kramer acepta un caso relacionado con los cuerpos desangrados. Antes de que ambos se den cuenta se ven inmersos en una red de intrigas que va más allá de lo que creían, y que supera por mucho a los crímenes normales que dominan Chicago.",
    "year": 2013,
    "authors": [
      "Tony Gimenez"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1246
  },
  {
    "title": "(PE) EL VAMPIRO DE SILESIA",
    "isbn": "9788445001714",
    "synopsis": "El prestigioso periodista y experto en temas paranormales Lorenzo Fernández Bueno se adentra en el terreno de la ficción con una novela de terror que sorprenderá a crítica y público.Marzo de 2009: el profesor Adriano Toscanelli, junto a un equipo de arqueólogos, descubre una fosa común en una isla de Venecia. En su interior se halla una cripta oculta tras los huesos de los apestados que fueron enterrados allí y el cuerpo de una mujer salvajemente torturada cinco siglos atrás.",
    "year": 2013,
    "authors": [
      "Lorenzo Fernandez Bueno"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1247
  },
  {
    "title": "JOVENES GUERREROS",
    "isbn": "9788494110382",
    "synopsis": "Un grupo de jóvenes amigos están en un pub cuando sobreviene un estallido de luz blanca que lo engulle todo: A partir de ese momento sus vidas entran en una espiral donde salen a relucir sus emociones soterradas, en una búsqueda entre mantener la relación de amistad o sumirse en la soledad o los celos. Al mismo tiempo, se dan cuenta, que desde el momento de la explosión, semejan tener ciertos poderes de los cuales se van haciendo conscientes poco a poco. Jóvenes guerreros es una novela fantástica, en donde se amalgaman múltiples referencias: cuentos clásicos, salpicados por humor, sensualidad; música que parece sonar en cada página, la fantasía, el horror y la ciencia ficción de H.P. Lovecraft, las percepciones de Huxley, el diario de unos acontecimientos acaecidos entre el 31 de octubre y el 1 de noviembre, Halloween, la historia de las Guerras Silenciosas, las sabrosísimas recetas para elaborar carne humana…",
    "year": 2013,
    "authors": [
      "Lou Wild"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1296
  },
  {
    "title": "LA PSIQUIATRA",
    "isbn": "9788494119644",
    "synopsis": "El caso de una paciente maltratada y aterrorizada se convierte en la pesadilla de la psiquiatra Ellen Roth. La mujer teme ser secuestrada por el hombre del saco. Se lo susurra a Ellen y luego desaparece sin dejar rastro. Nadie la ha visto ni sabe nada de ella. Ellen quiere encontrarla. Pero al intentarlo, se ve involucrada en un macabro juego del que no sabe como salir para salvar a la paciente y a sí misma. Solo puede intentar encajar las piezas de un rompecabezas diabólico. Mientras se precipita a un abismo de violencia, paranoia y terror, descubre que los problemas nunca no se arreglan solos…",
    "year": 2013,
    "authors": [
      "Wulf Dorn"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1309
  },
  {
    "title": "EL CUERVO",
    "isbn": "9789686756371",
    "synopsis": "El cuervo fue publicado por primera vez en 1845 y constituye la composición poética más famosa de su autor. Son notables su musicalidad, el lenguaje estilizado y la atmósfera sobrenatural que logra recrear. Poe afirmaba haber escrito el poema de forma muy lógica y metódica. Su intención era crear un poema que pudiese gustar tanto a las clases populares como a las personas de gusto más refinado, como explica él mismo en el ensayo que acompaña esta edición \"Filosofía de la composición\". La publicación de El cuervo convirtió a Poe en un personaje muy popular en su época. Aunque algunos críticos mantienen opiniones diversas acerca de su valor literario, el poema sigue siendo una de las composiciones más famosas que se han escrito en lengua inglesa. Esta edición incluye además, las versiones que hicieran del poema Stéphan Mallarmé y Charles Baudelaire y la traducción de Salvador Elizondo de Filosofía de la composición.",
    "year": 2011,
    "authors": [
      "Edgar Allan Poe"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1310
  },
  {
    "title": "PIROFOBIA",
    "isbn": "9788445000786",
    "synopsis": "La vida de Jason Evans parece perfecta: tiene una mujer a la que adora, un buen trabajo y muchos amigos. Nada se interpone en su camino hacia la felicidad, hasta que un desconocido comienza a enviarle inquietantes fotografías de un cementerio con unos enigmáticos mensajes escritos en la parte de atrás: «Estás muerto. Crees estar vivo, pero no existes.». Jason no tardará en descubrir que su vida no es tal como él siempre había pensado y poco a poco se verá envuelto en una macabra búsqueda: la de su propia tumba.",
    "year": 2013,
    "authors": [
      "Jack Lance"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1314
  },
  {
    "title": "PESADILLAS DE SANGRE",
    "isbn": "9788415615408",
    "synopsis": "En El favor, dos soldados comparten algo más que una amistad aun después de ser acribillados por el enemigo. Llegaremos a los límites de la cordura humana en El Desagüe, cuando un hombre queda con la mano atrapada en un lavabo. Indómitos es una tierna historia de zombis vista desde otra perspectiva. Acompañaremos a un joven demonio a su graduación en Posesión. En Ocasiones, un feliz matrimonio tiene extraños gustos en sus pasatiempos. En La Inspiración veremos hasta donde es capaz de llegar un escritor por conseguir la fama. Sin ojos veo es la asombrosa historia de una mujer que tiene extrañas visiones después de perder los ojos. Estos y otros relatos, componen una asombrosa antología que hará las delicias de los amantes del terror.",
    "year": 2014,
    "authors": [
      "Daniel Gutierrez"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1324
  },
  {
    "title": "RETALES",
    "isbn": "9788415615989",
    "synopsis": "Espectros, zombies, ratas, camiones,…, o alguien que durante años nos pareció la mejor persona del mundo. Todos ellos tienen algo en común. Son igualmente capaces de hacernos sentir una de nuestras más primitivas sensaciones, el miedo. Sin embargo, hubiera sido de locos mezclarlas todas en una misma historia, tal vez exagerado, como pegarse un tiro en la cabeza sólo porque tienes que sonarte los mocos. El resultado no solo sería demasiado escandaloso sino que no habría por dónde cogerlo. Sois vosotros, amigos, los que habéis de tejer un manto con estos terroríficos retales que se os ofrecen, un arrullo con el que cubriros el alma en vuestras noches de insomnio.",
    "year": 2014,
    "authors": [
      "Jose Antonio Garcia Santos"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1325
  },
  {
    "title": "CONDESA BATHORY, LA SEÑORA DEL HIDROGENO",
    "isbn": "9788494095825",
    "synopsis": "Edward Teller es un niño retraído del que se burlan todos sus compañeros. Hasta que un día, durante una excursión al ruinoso castillo de la Condesa Sangrienta en Transilvania, cae en una catacumba y se encuentra con la temida vampira. Desde ese episodio todos le respetan y así será hasta el final de sus días. El niño judío se convierte en un afamado científico que trabaja para el Gobierno de los EE.UU. en el proyecto de creación de la bomba de hidrógeno. Pero en su meteórica carrera Edward nunca ha estado solo. En la sombra siempre se perfila la figura de su Madre Oscura, quien le eligió desde pequeño para una importante misión que implica al mismísimo Poder en la Sombra de la Primera potencia Mundial y a varios de sus Presidentes.",
    "year": 2013,
    "authors": [
      "Juan Shreiber"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1358
  },
  {
    "title": "LA VENGANZA DEL DIEZ DE JULIO",
    "isbn": "9788494121685",
    "synopsis": "Tras una noche empañada por una extraña desaparición, el destino desata una serie de sucesos que, comprensiblemente, escapan a toda lógica. En la oscuridad alguien clama venganza y, frente a los lugareños, se presenta el Vengador dispuesto a devolver, sin contemplaciones, el daño infligido. Hablamos de un ser sediento de sangre y con el odio corriendo por sus venas. Ira y maldad en estado puro.\"",
    "year": 1900,
    "authors": [
      "P.m. Bassols"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1360
  },
  {
    "title": "LA ISLA",
    "isbn": "9788498007435",
    "synopsis": "La familia de su novia invita al joven Rupert Conway a pasar unas vacaciones con ellos de crucero por las Bahamas. Cuando, estando de pícnic en una isla desierta, su barco explota, Rupert no se preocupa demasiado: hay comida en abundancia, agua potable, y tanto su novia como la madrastra de esta y sus medio hermanas están para chuparse los dedos en bikini. Pero, cuando los demás hombres que conformaban esta pequeña expedición empiezan a aparecer asesinados, Rupert se da cuenta de que tiene un problema: no están solos en la isla y él, un adolescente, es el único que puede proteger a las mujeres del sádico que los acecha.",
    "year": 2012,
    "authors": [
      "Richard Laymon"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1408
  },
  {
    "title": "EL FIN DE LOS DIAS",
    "isbn": "9788445000816",
    "synopsis": "El director de documentales Kyle Freeman está pasando por una mala racha. Se enfrenta a la bancarrota y al olvido, hasta que acepta el encargo para hacer un documental nada corriente. En 1975, la secta del Templo de los Últimos Días se autoinmoló en una noche de violencia ritual. Desde entonces, se rumorea que los secretos místicos y las experiencias paranormales del grupo han permanecido ocultos tras su legado de asesinatos, perversiones sexuales y condenas de prisión. Al iniciarse el rodaje empiezan a sucederse una serie de hechos inexplicables: Kyle recibe inquietantes visitas nocturnas y descubre objetos espantosos que parecen advertencias dirigidas a él, mientras que sus entrevistados comienzan a morir de forma repentina. Kyle descubre, demasiado tarde, que está metido de lleno en el horrible legado de la secta y que existe una buena razón para que los implicados en el caso hayan mantenido silecio durante décadas.",
    "year": 2013,
    "authors": [
      "Adam Nevill"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1412
  },
  {
    "title": "GOTHIKA",
    "isbn": "9788445077658",
    "synopsis": "AMAR A UN VAMPIRO SÓLO PUEDE TENER UN FINAL PEOR QUE LA MUERTE Finales del siglo XVIII. La joven Analisa se ve acosada por extrañas y terribles pesadillas y por un sutil mal que parece estar consumiéndola poco a poco. Un día Analisa despierta dentro de un ataúd. Junto a ella reposa su tía, muerta. Cuando la joven escapa y se siente a salvo descubre que algo le ha ocurrido. Y siente la aguda punzada del hambre... Principios del siglo XXI. Alejo se gana el pan como teleoperador, mientras se documenta intensamente para la que será su gran novela. Para ello sale cada noche con Darío, el hermano de su novia, por el ambiente goth madrileño. Todo cambia el día que Alejo conoce a Ana, la mujer enigmática y fascinante que se convierte en su única obsesión.Gothika fue la novela ganadora del Premio Minotauro 2007.",
    "year": 2007,
    "authors": [
      "Clara Tahoces"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1418
  },
  {
    "title": "LA VENGANZA DE AUREK (RAVENLOFT)",
    "isbn": "9788448036751",
    "synopsis": "La historia de un hombre llevado por amor a los rincones más oscuros del mundo. Cuando la mujer de Aurek Nuiken es atacada y hecha prisionera por un perverso mago, Aurek tendrá que ir en busca del hechizo que le permitirá liberarla. Enfrentado a su propio tormento y a los monstruos del mundo de Ravenloft, Aurek será empujado al fi lo de la locura y enfrentado a una decisión que ningún hombre debería tener que tomar.Un nuevo título de la serie Ravenloft, el oscuro mundo de pesadilla creado por Wizards of the Coast. El mundo de Ravenloft es una referencia obligada dentro del género de terror.",
    "year": 2008,
    "authors": [
      "Tanya Huff"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1471
  },
  {
    "title": "EL ESPEJO DEL DIABLO",
    "isbn": "9788492594597",
    "synopsis": "En el tranquilo pueblo de Camino se ha producido un terrible asesinato que ha dejado consternados a todos sus habitantes. El cuerpo de Amanda, una adolescente retraída, ha aparecido quemado al lado de los cadáveres de dos miembros de su familia. La extraña muerte de la joven no sólo ha soliviantado a los convecinos, sino que ha noqueado el sensible interior de María, su mejor amiga. El destino hará que ésta coincida con Ángel, un joven apasionado por los temas paranormales dispuesto a desvelar el misterio que envuelve el lúgubre suceso. La única pista con la que cuentan es un siniestro espejo que Amanda regaló a María antes de morir. Junto con un grupo de amigos, María y Ángel se adentrarán a través del espejo en un oscuro mundo paralelo donde se ocultan las tenebrosas fuerzas del mal. Este espeluznante sendero sólo podrá llevarlos a la verdad o a la muerte, o quizá a ambas cosas.",
    "year": 2009,
    "authors": [
      "Miguel Martinez Saez"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1517
  },
  {
    "title": "LA IGLESIA ROJA",
    "isbn": "9788498005752",
    "synopsis": "Ronnie, de trece años, tiene un montón de problemas: mamá y papá se separan, su hermano Tim es un pelma, Melanie Ward o lo ama o lo odia, y le resulta cada vez más difícil seguir a Jesús. Además tiene que pasar todos los días por delante de la iglesia roja, donde se esconde el monstruo del campanario. El sheriff Littlefield también odia la iglesia; su hermano pequeño murió allí años atrás en un extraño accidente, y ahora él empieza a ver su fantasma. Archer McFall, el nuevo sacerdote, ha comprado la iglesia roja para albergar su Templo de los Dos Hijos. Los tres comparten un secreto de culpa y traición, un pecado que McFall y sus feligreses creen que solo hay una forma de lavar: con sangre.",
    "year": 2010,
    "authors": [
      "Scott Nicholson"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1598
  },
  {
    "title": "EL CIRCO DE LA FAMILIA PILO",
    "isbn": "9788498006254",
    "synopsis": "Will Elliott comenzó a trabajar en esta novela después de haberle sido diagnosticada esquizofrenia a los diecinueve años. ''El circo de la familia Pilo'' es su primera obra y ha sido todo un éxito, consiguiendo cinco de los premios más importantes del sector.«Tienes dos días para pasar la audición. Será mejor que la pases, colega. Vas a unirte al circo. ¿A que es la mejor noticia que te han dado nunca?» Este ultimátum, en boca de un trío de payasos psicóticos, arroja a Jamie al terrorífico universo alternativo del circo de la familia Pilo, un mundo limítrofe entre el infierno y la tierra desde el que se han perpetuado las mayores tragedias de la humanidad. Sin embargo, en este lugar poblado por seres espantosos, grotescos y monstruosos en el que la violencia y el salvajismo son la norma, Jamie descubre que su peor enemigo es él mismo. Cuando se aplica el maquillaje blanco en la cara se transforma en J.",
    "year": 2011,
    "authors": [
      "Will Elliott"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1618
  },
  {
    "title": "RUMORES DE LOS NO MUERTOS: 30 DIAS DE NOCHE Nº 1",
    "isbn": "9788448040291",
    "synopsis": "Primer volumen de la serie %1330 días de noche%13, ambientada en el mundo de la premiada serie de novelas gráficas y películas.El agente especial de la FBI Andy Gray solía tenerlo todo controlado. Pero eso fue antes de que la aterradora criatura que una vez había sido su compañero y amigo atacara a su familia. Ahora Gray busca respuestas pero sólo encuentra más preguntas y todas ellas parecen conducir a la aislada población de Barrow, Alaska, un lugaar que ya ha tenido su dosis de horror. Andy Gray no tiene ni idea de en qué se ha metido, y está a punto de descubrir lo peligrosas que pueden llegar a ser algunas leyendas cuando resultan ser reales.",
    "year": 2011,
    "authors": [
      "Steve Niles"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1634
  },
  {
    "title": "OMNIBUS GENEVIERE: LA VAMPIRA",
    "isbn": "9788448038502",
    "synopsis": "El mal tiene un nuevo enemigo... uno de su propia estirpe. Te presentamos a Genevieve Dieudonne. Es hermosa, fuerte, resuelta y valiente... y tiene más de cuatrocientos años. En los oscuros bosques y ciudades del mundo de Warhammer, Genevieve y sus inquietantes amigos combatirán las fuerzas del mal y la locura. Aún así, la sangre de vampiro que corre por sus venas la mantendrá en una constante lucha por resistirse al mal que late en su interior.«Yeovil nos ofrece un relato ingenioso que te atrapará en el preciso instante en que entres en su mundo y te dejará sin aliento y hambriento.» ENIGMA«Yeovil sobresale en el dominio de lo macabro y lo grotesco.» RPG.NET",
    "year": 2003,
    "authors": [
      "Jack Yeovil"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1645
  },
  {
    "title": "ABISMOS (INCLUYE LA NOVELA CORTA LA TEXTURA DE TU PIEL)",
    "isbn": "9788415156086",
    "synopsis": "“Abismos” es su primera y esperada antología, y a buen seguro que se convertirá en una antología antológica, valga la redundancia. Además, a excepción de “La bruma”, que ganó el Premio Liter y se publicó en la desaparecida revista “Galaxia”, todas las historias de este libro son inéditas, para mayor suerte de sus seguidores. “El huevo”, “La bruma”, “El tubo”, “El cine” y “La textura de tu piel” están llamadas a convertirse en clásicos del terror moderno, narraciones de una subyugante intensidad que te atrapan desde la primera línea sin remisión, desembocando de forma vibrante en finales certeros y sobrecogedores. En manos de este original y diabólico autor, por ejemplo, algo tan nimio como arrojar un huevo por la ventana puede desencadenar una tragedia de consecuencias imprevisibles. No lo dudes y asómate a los abismos… si te atreves. Al menos, como diría Clive Barker, “es bueno estar preparado para lo peor, antes de perder el aliento”.",
    "year": 2011,
    "authors": [
      "David Jasso"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1662
  },
  {
    "title": "NI DIOS NI AMO",
    "isbn": "9788492924806",
    "synopsis": "MaracenaMartín, un ciudadano corriente, despierta en el interior de un féretro. Todo indica que ha vuelto a nacer, pero en realidad... está muerto. Un extraño ángel, el vigilante del cementerio, le brindará información acerca de las preguntas que le atenazan. Y una nueva ¿vida? se desplegará ante él, plagada de situaciones que desconocía por completo. Pero nada es gratis, ni en la vida ni en la muerte. Martín deberá saldar su deuda asesinando a otro ser vivo... Mediante una narración absorbente, Francisco Baeza despliega una trama de asesinatos y reencarnaciones, con situaciones sobrecogedoras. Ganadora del IV Premio de Literatura de Terror Villa de Maracena, Ni Dios ni amo es una indagación en el Mal a través de la experiencia de un hombre que se reencarna en el cuerpo de otras personas para vivir momentos estremecedores. Una obra insólita, que aúna terror, mitología y crítica social.",
    "year": 2011,
    "authors": [
      "Francisco Baeza"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1687
  },
  {
    "title": "EL DESPERTAR DE LOS MUERTOS",
    "isbn": "9788493754495",
    "synopsis": "El despertar de los muertos’, una apasionante novela de Gareth Wood. En mayo de 2004, los muertos de todo el mundo están volviendo a la vida, hambrientos de carne humana. Mientras el número de no-muertos aumenta, un hombre reúne a su familia y amigos para comenzar un viaje épico a través de Canadá, con la esperanza de encontrar un refugio en el que permanecer a salvo de las hordas caníbales: un viaje que le llevará desde el despertar de los muertos hasta el fin de la civilización.",
    "year": 2010,
    "authors": [
      "Gareth Wood"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1705
  },
  {
    "title": "STAR WARS: LAS TROPAS DE LA MUERTE",
    "isbn": "9788448044510",
    "synopsis": "Cuando la barcaza prisión imperial Purga, hogar temporal de quinientos de los criminales más peligrosos de la galaxia, se avería en una zona alejada y deshabitada del espacio, su única esperanza parece residir en un destructor estelar a la deriva y aparentemente abandonado. Sin embargo, sólo la mitad del equipo de búsqueda que entra en él regresa, y trae consigo una terrible enfermedad, tan letal que en cuestión de horas la Purga al completo muere de las formas más horribles imaginables. La media docena de supervivientes de la Purga harán lo que sea para sobrevivir. Pero los muertos -desalmados, imparables e inexplicablemente hambrientos- se están levantando.",
    "year": 2010,
    "authors": [
      "Jose Luis Diez Schwerter"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1735
  },
  {
    "title": "EL ULTIMO AMANECER",
    "isbn": "9788492952298",
    "synopsis": "Luther Jacq es un viejo profesor de psiquiatría a punto de jubilarse, que convoca a sus cuatro mejores alumnos para leerles una carta que recibió hace años de su mejor amigo, Alex, ya desaparecido. Los muchachos, Divivier, Proust, De la Pierre y Gaumont, reaccionan de distintas maneras al relato, como se verá. Con el pretexto de solicitar sus opiniones como futuros psiquiatras, va desgranando la lectura de una espantosa experiencia. Alex era un hombre millonario que regresó cambiado de la guerra. Ambos eran de Marsella, y mantenían una estrecha y profunda amistad que se vio interrumpida por el estallido de la contienda, pues Luther Jacq fue declarado no apto para combatir y Alex sí. Durante una escaramuza militar, Alex se aproxima a un pequeño pueblo perdido en el sur de Francia con otros cuatro soldados a su mando. Así, encuentran a una anciana que les recibe con una escopeta.",
    "year": 2010,
    "authors": [
      "David Ferrer"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1739
  },
  {
    "title": "LOS LOBOS DE SERIEVA: III PREMIO INTERNACIONAL DE TERROR DE VILLA DE MARACENA",
    "isbn": "9788492924110",
    "synopsis": "Mijaíl Gorbachov está a punto de ser nombrado secretario general del Partido Comunista de la Unión Soviética. Toda Rusia se muestra esperanzada ante la idea del cambio, mientras en Serieva, una pequeña aldea cercana a Moscú, acaba de producirse un extraño y trágico desastre al que ni los científi cos ni la KGB consiguen dar explicación. Niños que vuelven a la vida para describir hechos aún no acaecidos, incomprensibles alteraciones del tiempo, y el fantasma de una bella mujer acompañada de sus lobos, obligarán al inspector de policía Alexander Presniakov a enfrentarse no sólo a los temibles sucesos que han devastado la aldea, sino a todo un sistema que encierra aún demasiados secretos",
    "year": 2010,
    "authors": [
      "Valeria Sabater"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1742
  },
  {
    "title": "CUENTOS DE TERROR",
    "isbn": "9788412027877",
    "synopsis": "Ambrose Bierce (1842-1913) cuenta con la ventaja de que su obra ha sobrevivido al misterio de su muerte, e incluso la ha superado en el interés sostenido de incontables lectores alrededor del mundo. Pensar en él como un \"escritor de cuentos de terror\" acaso no se ajuste perfectamente a la realidad. Sobre todo, Ambrose Bierce fue un trasgresor, un hombre de temperamento volátil y dueño de un sarcasmo tan certero como elegante. Lo que sí podemos afirmar es que dentro de su obra, que agrupa diccionarios demonológicos llenos de irónica reflexión, novelas góticas como El monje y la hija del verdugo (The Monk and the Hangman''s Daughter), ensayos, cuentos, artículos, epístolas de crueldad refinada, se cuentan quizás los mejores relatos de terror del período. Os ofrecemos en este libro los 10 mejores relatos de terror de Ambrose Bierce.",
    "year": 2019,
    "authors": [
      "Ambrose Bierce"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1766
  },
  {
    "title": "GRANDES RELATOS DE POE",
    "isbn": "9788494542206",
    "synopsis": "Prepárate para adentrarte en el universo de Allan Poe. Rebelión Editorial recopila sus grandes relatos en un único libro… Edgar Allan Poe es el gran maestro del relato corto y el creador del relato psicológico. Como buen romántico suele prevalecer el género gótico, especialmente en sus cuentos fantásticos. La lectura de Poe es fundamental. Su influencia en la literatura es absoluta, ya que sus textos forjaron toda una legión de genios cautivados por su magia; entre los cuales podemos destacar a Charles Baudelaire, lord Dunsany y H.P. Lovecraft. Edgar Allan Poe, ese genio desdichado y mórbidamente fascinante, es una de aquellas figuras que una vez que entran en tu vida sabes que jamás te abandonarán",
    "year": 2016,
    "authors": [
      "Edgar Allan Poe"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1768
  },
  {
    "title": "LA PESADILLA DE KENIA",
    "isbn": "9788417721763",
    "synopsis": "\"Cinco relatos entrelazados entre sí, inmersos en el terror y el suspense que generan los diferentes ambientes en los que transcurre una única historia. Divaga por terroríficos escenarios como una mansión supuestamente abandonada, una cabaña en mitad del bosque que guarda un oscuro secreto, un peculiar hospital… etc. Enfréntate a entidades malignas, psicópatas, asesinos y pistas, que quizá no te conduzcan a ningún sitio. Una única protagonista, un único objetivo, docenas de posibles caminos a seguir, que te conducirán a distintos y múltiples finales. ¿Serás capaz de llegar a todos ellos y descubrir qué te depara cada uno? Sumérgete en un bucle de atroces pesadillas, que quizá lleguen a robarte tu propio sueño. ¿Serás capaz de conducir a Kenia por el camino correcto, para llegar hasta su amado Michael?",
    "year": 2019,
    "authors": [
      "Lara Marco Llacer"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1831
  },
  {
    "title": "EL RITUAL",
    "isbn": "9788445000168",
    "synopsis": "Cuatro viejos amigos de la universidad se reúnen de nuevo para recorrer los parajes salvajes del Círculo Çrtico escandinavo y revivir los viejos tiempos. Pero pronto descubren que la vida les ha llevado por caminos diferentes y que poco tienen ya en común. Con el paso de los días, las desavenencias se van convirtiendo en obstáculos que añadir a los que presenta el terreno virgen y boscoso que pisan y a los problemas derivados de la poca preparación del grupo de excursionistas. Perdidos, hambrientos y rodeados por un bosque que no parece haber sido pisado durante milenios, no parece que la situación pueda empeorar, hasta que se topan con una desvencijada cabaña que esconde en su interior rastros de ritos ancestrales y de sacrifi cios paganos dedicados a una presencia que todavía habita el bosque. Una presencia inhumana que sigue de cerca sus pasos.",
    "year": 2012,
    "authors": [
      "Adam Nevill"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1933
  },
  {
    "title": "EL REINO DE LOS HUESOS",
    "isbn": "9788427037892",
    "synopsis": "¿Qué se esconde detrás de la fundación Glencore, cuya salida a Bolsa ha acabado con su histórico hermetismo? ¿Qué es lo que motivó a Bill Clinton a conceder el indulto presidencial a Marc Rich en medio de un grave escándalo político? ¿Qué motivó al rey don Juan Carlos, al premio Nobel Camilo José Cela o al empresario Fernando Fernández Tapias a brindarle su más incondicional apoyo cuando estaba acorralado por la justicia estadounidense? ¿Cuál es la estrecha relación que une a Rich con España? Esta es la historia de un escándalo. La primera biografía sin tapujos del hombre que transformó el mercado de las materias primas. Un relato rodeado de intrigas y traición sobre una de las figuras más polémicas de todos los tiempos…",
    "year": 2011,
    "authors": [
      "Stephen Gallagher"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1974
  },
  {
    "title": "CARAHUECA: NO PUEDES ESCAPAR DE LO QUE YA ESTA DENTRO",
    "isbn": "9788499980065",
    "synopsis": "Juan es madrileño, tiene siete años y una imaginación desbordante. Por las noches sufre los ataques de un intruso sin rostro que domina sus pesadillas sin que Luisa, su madre, pueda evitarlo. Mia, una niña londinense de doce, les lee a sus amigos de clase el misterioso cuento de Carahueca, un monstruo que quiere a toda costa algo particularmente especial de los niños. Desde ese mismo día, las vidas de Mia y de sus padres, Sue y John Farrow, se ven bruscamente alteradas. Separadas por miles de kilómetros pero íntimamente unidas por el miedo, las existencias de ambas familias darán un vuelco: los intrusos ya están en sus casas y no piensan marcharse sin aquello que quieren arrebatar desesperadamente a sus hijos.",
    "year": 2011,
    "authors": [
      "Nicolas Casariego"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1975
  },
  {
    "title": "RELATOS DE MIEDO EN CASTILLA LA MANCHA",
    "isbn": "9788477885528",
    "synopsis": "Lo fantástico y el miedo forman parte indisociable de nuestras vivencias, de nuestros recuerdos, de nuestros anhelos. Junto al gozo y su expresión más primaria y definitiva, la risa, están en la base de lo que las sociedades humanas han demandado desde siempre a sus contadores de historias y a sus artistas, en un arco temporal que se extiende del teatro griego a la televisión, pasando por la épica, el romancero, la juglaría, la comedia barroca, la novela decimonónica o el cine. Nunca antes se había abordado un estudio de la narrativa fantástica desde la perspectiva regional; y a través de Eduardo Verdejo, los textos y casos estudiados se tratan desde una perspectiva ciertamente novedosa. Se trata de una miscelánea con voluntad integradora en la que se funde lo clásico con lo moderno y lo contemporáneo y la tradición oral.",
    "year": 2009,
    "authors": [
      "Eduardo Verdejo"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1979
  },
  {
    "title": "LA MANSION DE LOS CUERVOS",
    "isbn": "9788496235533",
    "synopsis": "Este libro es una antología de cuentos que explora la temática de las casas hechizadas de manera variada, según el punto de vista de cada autor. Con prólogo de Alicia Mariño Espuelas y un bello poema introductorio de Luis Alberto de Cuenca, el libro pretende llegar al corazón de los amantes del género.En la literatura fantástica, el tema de las casas encantadas desvía la mirada hacia los secretos que encierran los antros misteriosos, que pueden ser meros habitáculos recónditos en ocasiones, pero en otras se trata de un cubil que da cobijo a espectros y fenómenos sobrenaturales; sin olvidar que la casa puede ser un ente vivo y fascinante, el personaje principal, el propio eje del horror... Tal como se demuestra en esta antología. Pero cuidado: una vez dentro ¡no hay salida posible!",
    "year": 2014,
    "authors": [
      "Angel Gomez Rivero"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2045
  },
  {
    "title": "CIUDAD HUMANA 3: GUERRA",
    "isbn": "9788494480232",
    "synopsis": "Jack ha ganado. Con Nacho muerto, Gonzalo desaparecido y Alejandro fuera de juego, no hay nadie que pueda detenerle.Su intrincada partida de ajedrez ha culminado con su designación como presidente, dándole carta blanca para llevar a cabo sus planes para acabar con Ciudad Humana.Mientras tanto, en Barcelona, los supervivientes de la expedición buscan desesperados el equipo robado, conocedores de que cada día que pasa sin hallar la vacuna de la gripe, el número de muertes aumenta.Pero, ¿qué fue de Gonzalo? Descúbrelo en la conclusión de la historia de Ciudad Humana y contempla las nubes de tormenta que se avecinan, arrastrando con ellas oscuridad, muerte... y guerra.Bienvenidos de nuevo a Ciudad Humana. El mejor lugar del mundo... para morir.",
    "year": 2015,
    "authors": [
      "Carlos J. Lluch"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2152
  },
  {
    "title": "EL ESPECTACULO DEL VAMPIRO",
    "isbn": "9788498004274",
    "synopsis": "En una calurosa mañana de agosto de 1963, por toda la ciudad rural de Grandville aparecen, clavados por todas partes, carteles que anuncian la única noche de función del gran espectáculo del vampiro. El plato fuerte que promete el afiche es a Valeria, extraordinariamente bella, y el único vampiro viviente en cautividad. Para tres adolescentes de la ciudad este es un evento que no pueden perderse. Aunque no está permitida la entrada a menores de edad, ellos están decididos a encontrar la manera de verlo. Lo que sigue es una historia de amistad y coraje, tentación y terror; una historia que tiene lugar cuando tres amigos van donde no deben y encuentran mucho más de lo que nunca imaginaron. A pesar de ser norteamericano, el nombre de Richard Laymon es más conocido por los lectores de Inglaterra, Australia, Nueva Zelanda y el resto del mundo, donde su literatura de terror es tan valorada como la de Stephen King.",
    "year": 2009,
    "authors": [
      "Richard Laymon"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2335
  },
  {
    "title": "EL SEÑOR DE LOS VAMPIROS",
    "isbn": "9788498006162",
    "synopsis": "AL FIN LLEGA LA ÚLTIMA PARTE DE LA TRILOGÍA DE LOS ''DIARIOS DE LA FAMILIA DRÁCULA'', EL ÉXITO DE JEANNE KALOGRIDISJeanne Kalogridis es autora de bestsellers como En el tiempo de las hogueras o El secreto de Mona Lisa. El señor de los vampiros es el último libro de su aclamada trilogía vampírica, para la que se ha documentado minuciosamente y que ha sido todo un éxito. Durante medio siglo, una hermosa mujer ha sido prisionera de la crueldad de un hombre. Se trata de Zsuzsanna, la otrora exquisita sobrina de Vlad Tsepesh, también conocido como Drácula. Ahora, a través de una ceremonia de sangre y pasión, Zsuzsanna está a punto de ser liberada por la caricia de una mujer, Elisabeth de Bathory, la hermosa y sensual condesa decidida a destruir a Vlad.",
    "year": 2010,
    "authors": [
      "Jeanne Kalogridis"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2337
  },
  {
    "title": "EL ARTE MAS INTIMO",
    "isbn": "9788498006193",
    "synopsis": "Para el asesino en serie británico Andrew Compton, matar es un arte: el arte más íntimo. Tras fingir su propia muerte para escapar de prisión, Compton se encamina hacia EE. UU. con la intención de seguir perfeccionando su talento. Torturado por sus perversos deseos, llevado a poseer y asesinar a chicos jóvenes, Compton se une a Jay Byrne, un playboy disoluto que ha llevado su arte a límites que ni siquiera él había imaginado. Juntos, dirigen sus miradas hacia un chico de la calle, Tran, americano de ascendencia vietnamita, y de belleza exquisita, a quien consideran la víctima perfecta. Esta novela va dirigida a aquellos que se atreven a entrar en donde lo sagrado y lo profano se convierten en uno.",
    "year": 2010,
    "authors": [
      "Poppy Z. Brite"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2339
  },
  {
    "title": "MOIRA",
    "isbn": "9788412051797",
    "synopsis": "Alessia Rosanera huye, aterrada. Sólo puede confiar en una persona y ni tan siquiera es eso; es una voz al otro lado del teléfono que la avisa de que la han encontrado y que debe cambiar de paradero si no quiere volver a la cárcel de cristal donde la tenían retenida.Por más de quince años ha estado presa en los subsuelos de una enorme mansión italiana regentada por una pareja de amantes inmortales y crueles vampiros que la han estado usando para cumplir sus metas. Unas a las que sólo pueden acceder gracias a la extraordinaria habilidad de la chica para predecir ciertos acontecimientos y atraer la suerte.Cuando Alessia decide huir cree que deberá enfrentarse sola a los peligros que enfrenta, pero no es verdad.",
    "year": 2019,
    "authors": [
      "Elizabeth Moore"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2376
  },
  {
    "title": "13 BALAS",
    "isbn": "9788445077719",
    "synopsis": "Una escalofriante revisión de las leyendas de vampiros Según la versión oficial, los vampiros se extinguieron en los años 80, cuando el agente del FBI Arkeley se enfrentó al último de ellos en un combate que a punto estuvo de acabar también con su vida. Pero, cuando la agente federal Caxton llama en mitad de la noche al FBI pidiendo ayuda, sólo el agente Arkeley sabe que está pasando: queda un vampiro. Escondido en un asilo abandonado, esperando el momento oportuno con la paciencia de la que solo un no muerto es capaz. Sólo hay un modo de resolver éste caso. Pero parece que los vampiros buscan algo más que la sangre de Caxton, algo sobre lo que su compañero guarda en silencio; algo que tendrá que averiguar o morirá.Sólo 13 balas separan a Caxton de Arkeley y los vampiros. Sólo 13 balas entre los vivos y los malditos.",
    "year": 2010,
    "authors": [
      "David Wellington"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2427
  },
  {
    "title": "AL ACECHO",
    "isbn": "9788493747688",
    "synopsis": "Septiembre. Una bella editora neoyorquina se retira a una solitaria cabaña, en la colina de una tranquila ciudad costera: Dead River, en temporada baja, donde espera la llegada de su hermana y amigos. Cerca, una familia de caníbales salvajes está al acecho en el sombrío bosque que la rodea, observando y esperando que salga la luna y caiga la noche… Y en pocas horas, cinco personas civilizadas y sofisticadas, así como un viejo y cansado sheriff aprenderán cuán primitivo somos debajo de la superficie, y que no existen límites ante el deseo de sobrevivir.",
    "year": 2009,
    "authors": [
      "Jack Ketchum"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2430
  },
  {
    "title": "LAS GUERRAS DE LOS VAMPIROS (TRILOGIA DE VON CARSTEIN)",
    "isbn": "9788448039844",
    "synopsis": "La aristocracia de la noche te da la bienvenida. De todos los vampiros que acechan el Viejo Mundo, los Von Carstein son los más infames. Sus meros nombres - Vlad, Conrad y Mannfred - conjuran imágenes de fatalidad, muerte y destrucción. Esta edición ómnibus recoge las tres novelas de Steven Savile sobre este linaje - Herencia, Dominio y Venganza - en un sangriento volumen que se adentra en las profundidades del mal.La trilogía sobre las Guerras de los Vampiros en un solo volumen. Los lectores podrán hacerse con todas las novelas sobre los vampiros del mundo de Warhammer adquiriendo este único volumen.",
    "year": 1901,
    "authors": [
      "Steven Savile"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2493
  },
  {
    "title": "FRANKENSTEIN",
    "isbn": "9788467030396",
    "synopsis": "Se trata de la edición más completa de una de las cimas de la literatura universal. Con ella se pretende acercar al lector a la versión original que Mary Shelley (1791-1851) construyó en agosto de 1816. Esta versión fue posteriormente revisada por Percy Shelley, marido de la escritora. La presente edición ofrece las dos versiones de la obra, además de una completa introducción y apéndices en los que se explican las modificaciones realizadas en sus diferentes versiones.",
    "year": 2009,
    "authors": [
      "Mary Shelley"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2495
  },
  {
    "title": "EL GATO NEGRO ; EL CUERVO",
    "isbn": "9788484344872",
    "synopsis": "Edgar Allan Poe .el mundo. muchos han querido imitarlo, pero jamas podran escribir como el ya que en cada uno de sus cuentos, se puede encontrar una faceta diferente del autor con alguno de sus problemas. el principal y mas localizado en todos, es el alcohol. sabida es su grave adiccion a la bebida y tambien que jamas se intereso mucho por salir adelante, ni de su enfermedad, ni por progresar economicamente. el gato negro conjuntamente con el poema \"el cuervo\", son los dos textos que nos dejo de legado poe, que relatan mejor que ningun otro la complejidad de su psiquis. foto: livra analizando fríamente esta obra, podemos encontrar varias similitudes entre su vida, y la vida del protagon...",
    "year": 2009,
    "authors": [
      "Edgar Allan Poe"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2632
  },
  {
    "title": "CORAZONES MUERTOS",
    "isbn": "9788498004830",
    "synopsis": "Segunda entrega de la serie Sookie Stackhouse. Título original: Living Dead in Dallas La protagonista tiene una racha de mala suerte. Su compañero de trabajo ha sido asesinado y ella es atacada por una criatura que le inflige un corte venenoso. Justo a tiempo, aparecen unos vampiros que le chupan el veneno de las venas. Sookie les debe la vida, y cuando estos le piden un favor, acepta. Pronto estará usando sus habilidades telepáticas para buscar a un vampiro desaparecido. Solo pone una condición: los vampiros deben prometer que se van a comportar y que no habrá bajas entre los humanos... Más fácil de decir que de hacer.",
    "year": 2009,
    "authors": [
      "Charlaine Harris"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2634
  },
  {
    "title": "EL ALMACEN",
    "isbn": "9788466640633",
    "synopsis": "Una aterradora novela escrita por uno de los autores favoritos de Stephen King.En Juniper, Arizona, nunca ocurre nada extraordinario. Así, el anuncio de la apertura de El Almacén supone una gran novedad. Todo lo que uno pueda querer estará bajo un mismo techo y a un precio increíble. Pero conviene tener cuidado con lo que uno quiere... Bill Davis es el único que es capaz de percibir el mal que bulle en torno a El Almacén. Y entonces empiezan a ocurrir cosas extrañas.",
    "year": 2009,
    "authors": [
      "Bentley Little"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2640
  },
  {
    "title": "SOMBRAS DE UNA VIEJA RAZA",
    "isbn": "9788496013667",
    "synopsis": "Meliot se enfrenta a la peor decisión de su vida; debe tomar partido por uno de los dos bandos en litigio y los odia a los dos por igual. Los miembros de la Vieja Raza están a punto de batirse en una lucha fraticida: la tiránica y poderosa aristocracia, en el gobierno, contra la plebe mediocre que inunda y controla las ciudades. Esta guerra le forzará a entrar en el juego que otros han dispuesto para él, a aliarse con renegados; se verá obligado a reclutar a viejas amistades olvidadas… mientras una extraña enfermedad le impide llevar una vida normal. Una novela de terror en la que la Sed de Sangre nublará el juicio de Meliot, instándole a elegir entre su Instinto y su Humanidad. Sombras de una Vieja Raza resultó finalista en la tercera edición del Premio Minotauro.",
    "year": 2009,
    "authors": [
      "Alejandro Guardiola"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2641
  },
  {
    "title": "DESCANSA EN PAZ",
    "isbn": "9788467031621",
    "synopsis": "Considerado por la Academia Sueca uno de los autores de mayor talento, aclamado por la crítica como el nuevo Stephen King y considerado por los lectores el sucesor de Stieg Larsson, el maestro escandinavo del terror se imagina en su nueva novela qué pasaría si Estocolmo fuese tomado por los zombies.Algo muy extraño está ocurriendo en la capital de Suecia: en medio de una inusual ola de calor, la gente se da cuenta de que no puede apagar la luz ni los aparatos eléctricos. De repente, una noticia sacude a la nación: en la morgue los muertos están resucitando. ¿Qué es lo que quieren? Lógicamente, volver a casa.",
    "year": 2010,
    "authors": [
      "John Ajvide Lindqvist"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2677
  },
  {
    "title": "TIERRA FRIA",
    "isbn": "9788492723256",
    "synopsis": "A finales del verano, un grupo de arqueólogos viaja a las costas de Groenlandia para buscar los restos de una civilización perdida: la que fundaron en el año 982 los primeros colonos escandinavos, que desaparecieron misteriosamente de la isla a comienzos del siglo XV. Sin embargo, cuando llega el duro invierno glacial, quedan atrapados entre el frío y la nieve, sin conexión a internet y rodeados por los espectros que todavía persisten en la zona. Así, aislados del mundo, los arqueólogos se enfrentarán a la escasez de alimentos y a sus propios fantasmas con el temor de que nadie, quizás, vaya a rescatarlos, pues un virus mortal acaba de propagarse por la tierra y amenaza con diezmar a la humanidad.",
    "year": 2010,
    "authors": [
      "Sarah Moss"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2679
  },
  {
    "title": "EL DIA DEL JUICIO MORTAL (TRUE BLOOD 11)",
    "isbn": "9788483652503",
    "synopsis": "El juicio final está en camino, y Sookie tiene una habilidad especial para situarse en medio del camino de los problemas; en particular cuando es testigo del ataque con bombas incendiarias al Merlotte''s, el bar donde trabaja. Dado que Sam Merlotte es conocido por su doble naturaleza, las sospechas inmediatamente recaen sobre los cambiantes de la zona. Sookie tiene otra opinión, pero antes de que pueda investigar surge algo, aún más peligroso. El amante de Sookie, Eric Northman, y su #niña# Pamela están tramando algo en secreto. Sea lo que sea, parecen decididos a mantener a Sookie al margen. Pero Sookie está igual de decidida a descubrir qué está ocurriendo. No puede permanecer de brazos cruzados cuando tanto su trabajo como su vida amorosa están amenazados. Sin embargo, cuanto más se progresa en sus planes, más consciente es de que la situación es más mortal de lo que nunca hubiera podido imaginar.",
    "year": 2011,
    "authors": [
      "Charlaine Harris"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2718
  },
  {
    "title": "LUNA DE PLATA",
    "isbn": "9788448040321",
    "synopsis": "David Wellington, con su particular estilo, finaliza la historia de licantropía que comenzó con Balas de Plata, y una vez más demuestra que es uno de los mejores escritores contemporáneos de terror.Los días se vuelven más fríos. Las noches, más largas. Y cada vez que sale la luna, la loba que habita su interior es más fuerte. Cheyenne Clark se ha transformado en una de esas bestias a las que tanto desprecia. Ronda el Círculo Polar Ártico en búsqueda de un antiguo secreto que podría liberarla de la maldición de la licantropía y devolverle su esencia humana.Pero entre Chey y su meta se interponen un cazador de hombres lobo que ha descubierto un arma diabólica para acabar con ellos, una mujer loba de varios siglos de edad con oscuros propósitos...",
    "year": 2011,
    "authors": [
      "David Wellington"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2772
  },
  {
    "title": "32 COLMILLOS",
    "isbn": "9788445000144",
    "synopsis": "En la brutal conclusión de la serie de vampiros iniciada con 13 balas, Laura Caxton y su némesis, la vampira Justinia Malvern, se encontrarán en el decisivo y sangriento enfrentamiento finalLaura Caxton lo ha perdido todo en el transcurso de su lucha contra Justinia: la vida de su familia y amigos, su libertad... puede que hasta su humanidad. Pero incluso ahora, reducida a una existencia solitaria como fugitiva, Laura no se rendirá. De hecho, tiene un plan que obligará a Justinia a ir a por ella y que provocará que las dos enemigas se enfrenten por última vez. Pero Justinia es astuta y también tiene sus planes, planes que incluyen a algunos de los amigos supervivientes de Laura, un batallón de policía y un ejército de esclavos no muertos.Tras 13 balas, 99 ataúdes, Vampiro Zero y 23 horas, 32 colmillos cierra la serie Vampire Tales de David Wellington de manera espectacular.",
    "year": 2012,
    "authors": [
      "David Wellington"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2775
  },
  {
    "title": "ZONA ZOMBIE",
    "isbn": "9788445078723",
    "synopsis": "En la continuación de Septiembre zombie y Ciudad zombie, un pequeño grupo de supervivientes encerrados en un búnker subterráneo tendrá que enfrentarse a los muertos vivientes si no quiere que su refugio se convierta en su tumba.Hace cuarenta y siete días, una agresiva enfermedad estuvo a punto de acabar con la raza humana. Miles de millones de vidas se apagaron en un abrir y cerrar de ojos.Pero la muerte ya no esel final. Los cadáveres, condenados a seguir caminando sobre la Tierra, dan caza a los pocos supervivientes de la plaga.Un pequeño grupo de hombres y mujeres, entre los que se encuentran algunos soldados, sobreviven atrapados en una base subterránea, con miles de cadáveres reanimados acechándolos a las puertas del búnker.En un escenario como éste, no es difícil que la situación se les vaya de las manos.",
    "year": 2012,
    "authors": [
      "David Moody"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2776
  },
  {
    "title": "EL NECRONOMICON",
    "isbn": "9788496525320",
    "synopsis": "Aunque los escépticos afirman que El Necronomicón es un tomo fantástico creado por H.P. Lovecraft, los auténticos investigadores de los misterios esotéricos del mundo saben la verdad: El Necronomicón es un volumen blasfemo de conocimiento prohibido escrito por el árabe loco, Abdul Alhazred. Incluso hoy, a pesar de las tentativas por destruir todas las copias en cualquier idioma a lo largo de los siglos, aún existen algunos ejemplares, escondidos.",
    "year": 2005,
    "authors": [
      "H.p. Lovecraft"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3278
  },
  {
    "title": "VLAD EL EMPALADOR: EN BUSCA DEL AUTENTICO DRACULA",
    "isbn": "9788495537966",
    "synopsis": "El historiador y autor de novelas policíacas M.J. Trow separa con paciencia los enmarañados hilos de la historia y el mito de este personaje, para dejar al descubierto al hombre de carne y hueso, que inspiró al personaje de ficción, el conde Drácula.",
    "year": 2003,
    "authors": [
      "M.j. Trow"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3279
  },
  {
    "title": "TRILOGIA DEL ABISMO: LOS BOTES DEL GLEN CARRIG; LA CASA EN EL CON FIN DE LA TIERRA; LOS PIRATAS FANTASMAS",
    "isbn": "9788477025085",
    "synopsis": "Este libro –cuenta William H. Hodgson en su introducción a «Los piratas fantasmas»– puede ser considerado el último de un grupo de tres. El primero se publicó bajo el título de «Los botes del “Glen Carrig”»; el segundo, como «La casa en el confín de la Tierra»; por fin, este tercero, completa lo que, quizá, pueda ser considerado una trilogía; pues, aun cuando los tres difieren mucho en los contenidos, todos ellos coinciden en una determinada forma de tratar unos conceptos elementales. Con este libro, el autor cree que cierra una puerta, en cuanto a lo que a él concierne, sobre una determinada fase de su etapa creadora. «Los botes del “Glen Carrig”» (1907), relata unos hechos sorprendentes en los que se ven envueltos los tripulantes de un buque náufrago. La historia está llena de colorido, aventuras y extraños sucesos, y poblada por las criaturas fantasmales y extraordinarias tan propias de Hodgson.",
    "year": 2005,
    "authors": [
      "William H. Hodgson"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3286
  },
  {
    "title": "LA LLAMADA DE LA SANGRE",
    "isbn": "9788498001396",
    "synopsis": "Robert McGee es un hombre que vive bajo una oscura nube. Es incapaz de escapar al alcoholismo y a la violencia que se han convertido para él en una segunda naturaleza. Poco después de asentarse en una granja decrépita de Missing Mile, mata a su mujer y a su vástago menor antes de suicidarse. Solo queda vivo Trevor, su hijo de cinco años... Veinte años después, Trevor regresa a la casa en la que vivió y murió su familia. Es entonces cuando conoce a Zachary Bosch, un pirata informático de Nueva Orleáns que huye de la ley.",
    "year": 2005,
    "authors": [
      "Poppy Z. Brite"
    ],
    "categories": [
      "Narrativa de terror"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3299
  },
  {
    "title": "EL MAPA DE LAS ISLAS",
    "isbn": "9788419172105",
    "synopsis": "Las islas esconden tesoros. Las islas son para desconectar del ruido y encontrarse. En las islas es donde sobrevive lo desconocido. El misterio, el miedo, la aventura, el placer. Debería alarmarnos que muchas estén desapareciendo. Día a día, islas antiguas que han presenciado mil milagros desaparecen por culpa del cambio climático. Sin embargo, el ser humano destruye, pero también crea. Para bien y para mal. Así que aparecen nuevas islas: por ambición territorial, para satisfacer el turismo, por capricho de millonarios y por necesidades científicas.Son muchas. La isla Runit, donde Estados Unidos almacena 73.000 m3 de residuos radiactivos bajo una cúpula amenazada por la subida de las aguas. Seasteading, la utopía financiada por el dueño de PayPal que busca construir viviendas en el mar independientes de cualquier jurisdicción nacional. Las fortalezas marinas en el Támesis, o las cárceles y manicomios cercanos a Venecia.",
    "year": 2022,
    "authors": [
      "Alastair Bonnett"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5
  },
  {
    "title": "LA FRONTERA INVISIBLE",
    "isbn": "9788401027345",
    "synopsis": "El último viaje de Javier Reverte ¿Dónde se encuentra la línea que separa Asia de Europa? ¿Dónde comienza Oriente entendido como geografía y como sentimiento? Javier Reverte escogió esa frontera vaporosa y vulnerable, la más antigua del mundo, para realizar su último viaje. Eligió como puerta de entrada Estambul y su magnífico estrecho del Bósforo para despues adentrarse en tren hasta remotas tierras iraníes. El resultado es un recorrido hermoso y nostálgico que se detiene tanto en las páginas de la historia antigua -tras la fulgurante estela de Alejandro Magno- como de la contemporánea -las guerras y revoluciones que marcaron el convulso siglo XX-, y que nos recuerda por que Javier Reverte fue el mejor escritor de literatura de viajes en lengua castellana.",
    "year": 2022,
    "authors": [
      "Javier Reverte"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 7
  },
  {
    "title": "CANTA IRLANDA: UN VIAJE POR EL EYRE",
    "isbn": "9788401346873",
    "synopsis": "Javier Reverte vuelve a la literatura de viajes en este fascinante recorrido por la salvaje Irlanda.Canta Irlanda es un libro en el que se reúnen y confunden el lirismo y el viaje, los caminos de tierra y los caminos de la poesía. Irlanda es un país crecido sobre la leyenda, sobre el sufrimiento histórico y sobre las canciones populares.",
    "year": 2014,
    "authors": [
      "Javier Reverte"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 25
  },
  {
    "title": "ROMA DESORDENADA: LA CIUDAD Y LO DEMAS",
    "isbn": "9788419207470",
    "synopsis": "«Un libro que estaba esperando a su autor. Esta Roma desordenada cumple con todas las promesas de felicidad que los viajeros del mundo hemos asociado a las palabras Italia o Roma».IGNACIO PEYRÓRoma nos permite ser voyeurs de nuestra propia historia. De las tumbas de los etruscos a la mundana Via Veneto, de Nerón a Pasolini, pasando por Caravaggio, Bernini, Borromini y Winckelmann —con escala española en Alberti, Zambrano o Gaya—, este es un libro que se propone juntar de nuevo las piedras de una mampostería eterna para contarlo todo otra vez de la ciudad que lo sabe todo.",
    "year": 2022,
    "authors": [
      "Juan Claudio de Ramon"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 44
  },
  {
    "title": "TERRITORIOS IMPROBABLES",
    "isbn": "9788417248826",
    "synopsis": "«Originalidad, solidez y belleza, tres cualidades de la arquitectura literaria de Pedro Torrijos. El talento de un relator de historias fascinantes en las que querrásquedarte a vivir»,Raquel Martos«Nunca sé si Pedro Torrijos está loco o es un genio. Supongo que es una mezcla. Lo que si sé es que me encanta leer lo que escribe»,Juan TallónLo que hacemos los seres humanos es construir. Desde ese instante eléctrico en el que ponemos un pie en el suelo por primera vez pero luego resulta que debajo del pie hay una pieza de Lego que habíamos tirado antes desde la cuna, y entonces la cogemos y la encajamos con otra. Sí, construimos. Construimos una vida, construimos un amor, construimos familias, casas, carreteras, ciudades, aeropuertos y naves espaciales. Transformamos lugares en lugares nuevos. A veces son cambios mundanos. A veces son asombrosos.",
    "year": 2021,
    "authors": [
      "Pedro Torrijos"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 53
  },
  {
    "title": "HISTORIAS DE NUEVA YORK",
    "isbn": "9788490563786",
    "synopsis": "Ciertos conocimientos son perfectamente innecesarios. Se puede vivir muy feliz sin saber con que truculencia surgió la cúpula del rascacielos Chrysler, por que los Yankees son el equipo supremo en Nueva York, cuál es la relación entre Arabia Saudí y la cerveza de Brooklyn, por que la grasa de los filetes es más amarillenta que en Europa, en que bar bebió Dylan Thomas su último whisky o dónde sirven las mejores hamburguesas de Manhattan. Historias de Nueva York habla de esas cosas. Tambien habla de una ciudad rugiente y fabulosa, de una jornada negra de septiembre, de un grupo de personas y de tres amigos inolvidables.",
    "year": 2014,
    "authors": [
      "Enric Gonzalez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 117
  },
  {
    "title": "(I.B.D.) AMERICA DEL SUR RUTA AZUL 1",
    "isbn": "9788418435577",
    "synopsis": "«Cuando un hombre y una moto conectan, lo extraordinario ocurre.»Emilio ScottoSi usted cree en la reencarnación o en vidas pasadas, entonces Emilio Scotto es Marco Polo o Cristóbal Colón o David Livingstone. Porque en la tradición de los grandes exploradores, Emilio Scotto se embarcó en un viaje que nunca se había realizado, solo que en su caso se estableció alrededor de un mundo aparentemente conocido y explorado. Lo que encontró fue todo lo contrario. Su aventura fue tan aterradora y peligrosa como cualquiera realizada por aquellos grandes hombres de leyenda. Esta es la verdadera historia del más grande viaje que un niño jamás haya podido imaginar y un hombre haya podido realizar, escrito en primera persona y en tiempo presente. Y es por eso que la aventura de Emilio pertenece ya al acervo cultural de nuestra época.",
    "year": 2020,
    "authors": [
      "Emilio Scotto"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 135
  },
  {
    "title": "LA MEMORIA DEL VIENTO: PRIMERA VUELTA AL MUNDO DEL JUAN SEBASTIAN EL CANO (1928-1929)",
    "isbn": "9788494788079",
    "synopsis": "El 1 de agosto de 1928 zarpa del puerto de Cádiz rumbo a Cabo Verde el flamante buque escuela de la Armada Española Juan Sebastián de Elcano, una embarcación de 113 metros de eslora y cuatro palos que había sido botado apenas un año antes y que iniciaba así su primera circunnavegación. A bordo se encontraba Cristobal Serrán Pagán, nacido en Ceuta en 1906, que era el ayudante de cámara del segundo comandante. Pese a su origen humilde, la curiosidad insaciable y el entusiasmo del joven marinero le llevaron a ir escribiendo un diario de lo que en definitiva iba a ser la aventura de su vida. Al mismo tiempo fue tomando fotografías y guardando recortes de periódicos, postales, etc., de los puertos donde recalaba. El resultado de aquello es este libro asombroso.",
    "year": 2018,
    "authors": [
      "Cristobal Serran Ortiz"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 159
  },
  {
    "title": "LARGA DISTANCIA",
    "isbn": "9788416665129",
    "synopsis": "\"Larga distancia\" es un clásico de la crónica en español: un libro que cambió el modo de pensar las relaciones entre periodismo y literatura. Los relatos de viaje reunidos en este volumen son fruto de ese placer que consiste en «hacer de la mirada pretendidamente neutra del reportero un ojo caprichoso.» La mirada de Caparrós sabe encontrar el detalle elocuente, la escena diminuta que lo dice todo, y logra en cada caso hacernos cómplices de esa revelación. Ya se trate de las luchas de los cocaleros bolivianos o de las guerrillas peruanas, los recorridos por Pekín, Shanghái y Hong Kong, la decadencia de Moscú, o los complicados lazos entre religión y poder en Haití, escribir es, como la vida, un viaje de descubrimiento. Por estas crónicas, el autor ganó el Premio Rey de España de periodismo.",
    "year": 2017,
    "authors": [
      "Martin Caparros"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 166
  },
  {
    "title": "VENECIA",
    "isbn": "9788419168023",
    "synopsis": "«En Venecia, el pasado y el presente se entretejen de forma curiosa, los venecianos no se han recuperado del todo de la pérdida de la gloria, quizá no la hayan aceptadosiquiera, de modo que en el fondo de sus pensamientos, su ciudad sigue siendo laSerenísima, la Novia del Adriático. Esta mezcla de resignación y persistencia da a lagente un toque de melancolía, una tristeza semejante a la laguna, lisa y seca.»A menudo clasificado como el mejor libro de viajes jamás escrito, Venecia no es niuna guía ni un libro de Historia sino una apasionada inmersión en la vida y en elcarácter venecianos. Jan Morris logra capturar el temperamento y el alma acuática dela ciudad guiándonos por sus calles a través de sus sonidos, olores, luces y colores. No hay rincón de Venecia que no haya investigado y al que no haya devuelto la vida.Jan Morris visitó Venecia por primera vez de joven durante la Segunda GuerraMundial siendo el soldado James Morris.",
    "year": 2022,
    "authors": [
      "Jan Morris"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 173
  },
  {
    "title": "EL BUSCADOR DE ESENCIAS",
    "isbn": "9788419207340",
    "synopsis": "El experto viajero Dominique Roques nos muestra el origen y todo lo que ha rodeado históricamente la elaboración de los perfumes desde la recolección del incienso en la Antigüedad hasta la industria actual. Los perfumes son fascinantes",
    "year": 2022,
    "authors": [
      "Dominique Roques"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 190
  },
  {
    "title": "POLO SUR: RELATO DE LA EXPEDICION NORUEGA A LA ANTARTICA DEL FRAM 1910-1912",
    "isbn": "9788493695057",
    "synopsis": "Nunca existió «la carrera por el polo Sur».Amundsen, llegó, vio y venció.Pero su hazaña en el Polo fue ensombrecida por un enfermizo sensacionalismo que glorificó y encumbró a un perdedor incompetente: el capitán Scott, cuya expedición, víctima de una incontable sucesión de decisiones erróneas, acabaría inútilmente con su vida y con la de sus cuatro compañeros.Sin duda, la prensa ganó antaño la carrera del morbo pero, hoy día, la historia reconoce el suicidio de Scott y el impecable estilo de Amundsen, cuya planificación evaluó y previó hasta el más mínimo detalle... Considerado insensible y calculador por su «cómoda victoria» frente al hielo, el lector descubrirá en esta amena narración, no exenta de cierto sentido del humor, que esta imagen no podría estar más lejos de la realidad:Amundsen era un enamorado de las tierras polares, y todos sabemos que los enamorados no son insensibles ni calculadores.",
    "year": 2010,
    "authors": [
      "Roald Amundsen"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 194
  },
  {
    "title": "LIBANO-PALESTINA: VIAJE A ORIENTE",
    "isbn": "9788493868925",
    "synopsis": "Procedentes de Alejandría, Flaubert y su amigo Maxime du Camp emprenden en Beirut, ciudad de partida de esta segunda parte de \"Viaje a Oriente\", un largo periplo que, del 19 de julio al 19 de diciembre de 1850, les llevará desde Líbano hasta el Pireo, pasando por Palestina, Siria, Asia Menor y Constantinopla.",
    "year": 2011,
    "authors": [
      "Gustave Flaubert"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 196
  },
  {
    "title": "LA VUELTA AL MUNDO EN MIL Y UN DIAS",
    "isbn": "9788498271126",
    "synopsis": "Dar la vuelta al mundo es el sueño de muchos, y Julio Verne nos ha enseñado cuando éramos pequeños que la precisión y la rapidez son claves para alcanzar este cometido. Jorge Sánchez, en cambio, hace del viaje una forma de vida, y su objetivo no es batir un récord temporal ni llegar a destino, sino aprender de cada momento del itinerario y hacer que valga el estar allí. Así es que nos invita en su libro, La vuelta al mundo en mil y un días, a acompañarlo en una aventura que es a su vez la manera de ponerse frente al mundo para conocerse mejor, para romper con los prejuicios y las concepciones que heredamos de nuestro lugar de nacimiento y ser un poco más ciudadano del mundo. Y por ello, este autor nacido en Barcelona emprende el recorrido que lo llevará a concretar una verdadera travesía por los sitios más distantes de nuestro planeta.",
    "year": 2008,
    "authors": [
      "Jorge Sanchez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 199
  },
  {
    "title": "LAS RUTAS DEL EXILIO",
    "isbn": "9788496434028",
    "synopsis": "Las rutas del exilio es un nuevo concepto de libro de viajes que aúna historia, periodismo y guía de viajes, en un intento por acercar al turista nuevos paisajes y nuevas propuestas viajeras. Este título comprende: 10 rutas históricas por la península Ibérica y sur de Francia. 18 rutas para realizar bien a pie, bien en coche por los espacios históricos por los que transcurrió el exilio tras la guerra civil española. 22 mapas detallados de las rutas, tanto las históricas como las actuales. Más de 130 fotografías de diferentes épocas que ilustran el fenómeno del exilio. Las rutas del exilio proponen nuevas formas de recorrer espacios muy transitados como Pirineos, Parque Natural de Cadí-Mixeró, el Empordà catalán, el sur de Francia... en travesías aptas para todo tipo de viajero.",
    "year": 2007,
    "authors": [
      "Marc Ripol"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 202
  },
  {
    "title": "MANUAL PARA VIAJEROS Y LECTORES EN CASA: GALICIA Y ASTURIAS",
    "isbn": "9788475068688",
    "synopsis": "Descatalogada desde hace años, esta obra se reedita en homenaje al aniversario de la muerte de Richard Ford, uno de esos grandes viajeros británicos del siglo XIX. La edición se ha completado, revisado y dividido en siete tomos, constituyendo, por primera vez en español, la obra completa reunida. Volumen dedicado a Galicia y Asturias.",
    "year": 2009,
    "authors": [
      "Richard Ford"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 204
  },
  {
    "title": "LAS TRES PUERTAS DEL MEDITERRANEO",
    "isbn": "9788493585716",
    "synopsis": "Ciudades cosmopolitas, bisagras entre Oriente y Occidente, densas de Historia y en historias. El periodista Daniel Rondeau, un extraordinario conocedor de la realidad urbana de estas tres capitales, nos presenta en su estilo cercano y vibrante el mejor de los paseos posibles. Tánger, recreo melancólico de aventureros y artistas, con sus fumadores de kif, sus misterios, sus aromas evocadores; Alejandría, la capital de la memoria y el saber; Estambul, erudita, incansable, inabarcable, la justamente llamada “ciudad-universo”. Anécdotas bien narradas, entreveradas por un profundo conocimiento de su historia, y un declarado amor hacia las tres ciudades son los ingredientes de esta estupenda trilogía, hábilmente perfilada por su reconocido y premiado autor.",
    "year": 2008,
    "authors": [
      "Daniel Rondeau"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 205
  },
  {
    "title": "MALLORCA, OBERT TOT L ANY",
    "isbn": "9788498095180",
    "synopsis": "La Mallorca de tot l’any, viscuda i narrada per Xavier Moret.Segons l’escriptor i viatger Lawrence Durrell, hi ha una categoria d’humans que senten una atracció irresistible per les illes; es tracta delsillòmans. Xavier Moret, que és un d’aquests individus, ha escrit un llibre deliciós sobre una illa que tenim molt a prop, Mallorca, i que no sempre valorem com el que és: un paradís a l''abast. En un temps en què ens han acostumat a sospirar pels paisatges llunyans i exòtics, sovint ens costa fer-nos a la idea que un lloc tan proper també pot ser meravellós. I ho és, per molts nyaps urbanístics que s’hi hagin fet en nom del gran negoci del turismeMallorca, obert tot l’any va més enllà dels tòpics i convida el lector a recórrer amb ulls de viatger els diversos paisatges de la gran de les Balears, Hi trobarem ciutats, pla, muntanya i una costa preciosa puntejada d’oliveres centenàries.",
    "year": 2022,
    "authors": [
      "Xavier Moret"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 220
  },
  {
    "title": "EUROPA NOMADA",
    "isbn": "9788460893721",
    "synopsis": "¿Es posible vivir auténticas aventuas en Europa? Miquel Silvestre, el mejor comunicador nómada del panorama viajero, nos demuestra con su particular estilo y personal sentido del humor que no solo es posible sino que están al alcance de cualquiera que realmente desee viajar de un modo diferente al de los tours organizados y la guías típicas.",
    "year": 2016,
    "authors": [
      "Miquel Silvestre"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 223
  },
  {
    "title": "¡EH, PETREL!: CUADERNO DE UN NAVEGANTE SOLITARIO (12ª ED.)",
    "isbn": "9788426156716",
    "synopsis": "¡EH, PETREL! CUADERNO DE UN NAVEGANTE SOLITARIO Julio Villar En su ligero Mistral, desde que salió de Barcelona en 1968 hasta que llegó al puerto de Lequeitio en el verano de 1972, Julio Villar recorrió unas 38.000 millas marinas. Fue una vuelta al mundo vivida sin prisas, saboreada, tranquila, a veces dramática. Pero el relato de sus peripecias no sigue el rumbo habitual en este tipo de libros. Aunque evoca inolvidablemente sus largos periplos de navegación y escalas, el propósito de Julio Villar ha sido recoger el curso anímico de su deambular. ¡Eh, Petrel! oscila entre la divagación lírica y sus escuetas anotaciones del cuaderno de bitácora. Sus párrafos rozan más de una vez la estructura de un poema y hay en ellos asombro y fervor hacia Walt Whitman, inquietas preguntas y sentimientos “de una sencillez y de una pureza que sólo hace muchos, muchos años, cuando era niño, era capaz de sentir”.",
    "year": 1989,
    "authors": [
      "Julio Villar"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 224
  },
  {
    "title": "DIARIOS DE KOLIMA",
    "isbn": "9788417496135",
    "synopsis": "Hay en la Rusia oriental una carretera mítica, una especie de Ruta 66 donde la Historia del comunismo más sanguinario se cruza con el carácter extremo de la temperatura siberiana y su inherente despoblación. Los mapas la denominan Autopista M56. Los locales la conocen, simplemente, como Trassa (La Ruta). Sin embargo, su nombre más legendario es el de Carretera de los Huesos, porque bajo ese pavimento maltrecho por el que apenas circula nadie están enterrados, para darle firmeza al suelo, miles de los prisioneros del Gulag que la construyeron por orden de Stalin.El prestigioso reportero polaco Jacek Hugo-Bader, heredero de Ryszard Kapuscinski, ha recorrido en autoestop los 2.025 kilómetros de esta vía. El suyo no es solo un viaje al terrible pasado soviético que retrataron Varlam Shalámov o Aleksandr Solzhenitsyn. Es sobre todo un descenso al alma de las personas que hoy habitan este infierno helado.",
    "year": 2019,
    "authors": [
      "Jacek Hugo-Bader"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 226
  },
  {
    "title": "EL OGRO: BIOGRAFIA DE UNA MONTAÑA Y LA DRAMATICA HISTORIA DE SU PRIMERA ASCENSION",
    "isbn": "9788498294347",
    "synopsis": "La tarde del 13 de julio de 1977, tras convertirse en los primeros escaladores en alcanzar la cumbre del inexpugnable Ogro (una de las montañas más difíciles del mundo), Doug Scott y Chris Bonington iniciaron el largo descenso de la montaña. Antes de iniciar el primer rápel, Scott sufre una caída y se fractura las dos piernas. A partir de ese momento se inicia una lucha desesperada por sobrevivir. El legendario montañero Doug Scott construye en este libro la biografía de esta enigmática cumbre. Para situarnos en el contexto Scott investiga meticulosamente la geografía y la historia de esta montaña para luego entrar de lleno en el relato, largo tiempo esperado y muy personal, de la ascensión que él y Bonington realizaron. El descenso dramático les exigió una semana, y durante el cual Scott sufrió la fractura de ambas piernas y Bonington el aplastamiento de varias costillas.",
    "year": 2018,
    "authors": [
      "Doug Scott"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 237
  },
  {
    "title": "EL ULTIMO VERANO DE LA URSS",
    "isbn": "9788418141379",
    "synopsis": "Se cumplen en 2021 treinta años del fin de la Unión de Repúblicas Socialistas Sovieticas. En el verano 1991, Sara Gutierrez inició en Ucrania un viaje para cruzar el país del mar Báltico al mar Negro. Al no disponer de permiso oficial, lo hizo en trenes nocturnos, apenas controlados por las autoridades sovieticas. Desde Leningrado, que quince días antes había sido renombrada San Petersburgo por sus habitantes, se desplazó a Tallin, Riga, Vilna, Lvov, Kiev y Odesa. Siete ciudades de cinco repúblicas donde las estrellas rojas y los emblemas de la hoz y el martillo comenzaban a convivir con las hamburguesas de McDonalds. Acompañaba a la autora una nativa de Uzbekistán que nunca había viajado sola ni visto el mar.",
    "year": 2021,
    "authors": [
      "Sara Gutierrez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 245
  },
  {
    "title": "ALEJANDRIA: HISTORIA Y GUIA",
    "isbn": "9788493668549",
    "synopsis": "Alejandría es la ciudad de los Ptolomeos, del amor suicida de Cleopatra y Marco Antonio, de Arrio y San Atanasio, de las matemáticas y la teología, del “Faros” que dio luz durante siglos., pero sobre todo es la ciudad del mismo hijo de Zeus, cuyos restos nadie ha sido capaz de encontrar entre la Rue Nebi Daniel y la Rue Rosette; es la ciudad que comenzó como fabulosa leyenda a partir de aquel extraño suceso en Siwa y que quedó plasmada cuando... “tras descender del caballo y arrojar al suelo su manto de jinete macedonio, Alejandro trazó el plano de su distribución sobre la arena y fijó el criterio por el que se habría de edificar”. No mucho después, aquella urbe se convirtió en eje del mundo mediterráneo…, del mundo. Esta edición recoge los extraordinarios textos de Forster, en los que el esplendor de esta ciudad aún vive para la mirada atenta que sabe descubrirlo de su mano, Alejandría, Historia y Guía y Faros y Farallón.",
    "year": 2009,
    "authors": [
      "Edward Morgan Forster"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 246
  },
  {
    "title": "UNA HISTORIA DE NUEVA YORK",
    "isbn": "9788416440900",
    "synopsis": "Publicada en 1809, esta novela satírica fue escrita, supuestamente, por un viejo cascarrabias llamado Diedrich Knickerbocker(heterónimo del autor). El mismo Irving participó en una especie de campaña de marketing viral del libro, escribiendo anuncios en los periódicos de Nueva York en los que se buscaba al tal Knickerbocker.Contado desde el punto de vista de Knickerbocker, este libro es una crónica que abarca cincuenta años, comenzando en la decada de 1600, de la historia de la ciudad Nueva York bajo el gobierno holandes. Novela hilarante y tremendamente entretenida.Tal fue su influecia que los neoyorkinos pasaron a conocerse como \" Knickerbocker\". No hay nada que se le parezca en la literatura americana temprana y Dickens, entre otros, tuvo un especial interes por esta obra.",
    "year": 2016,
    "authors": [
      "Washington Irving"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 251
  },
  {
    "title": "GRECIA-ITALIA: VIAJE A ORIENTE",
    "isbn": "9788493868994",
    "synopsis": "Procedentes de Constantinopla, Flaubert y su amigo Maxime Du Camp emprenden en Atenas la tercera parte del Viaje a Oriente, una última etapa que, de diciembre de 1850 a junio de 1851, les llevará desde Grecia hasta Italia. La ciudad de Venecia pondrá fin a esta gran aventura de casi dos años de duración, en la que partiendo de París recorrieron Egipto, Líbano, Palestina, Siria y Asia Menor.El Peloponeso, Nápoles, Roma o Florencia forman parte del itinerario de Flaubert en esta etapa final de su viaje por Oriente.Ilustrado con numerosas fotografías de la época.",
    "year": 2012,
    "authors": [
      "Gustave Flaubert"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 256
  },
  {
    "title": "HISTORIAS DE ROMA",
    "isbn": "9788490564103",
    "synopsis": "Roma es una ciudad de ciudades. Irresistiblemente caótica, en sus calles impregnadas de la pausada melancolía de un pasado de piedras milenarias abundan los lugares y los instantes mágicos. Historias de Roma no es una guía turística ni un compendio de tópicos, sino un recorrido personal por una Roma fascinante, en ocasiones secreta. En sus páginas encontrará el lector una sucesión de historias, personajes, momentos y escenarios romanos: los gatos, las pinturas del Caravaggio, la casa y la tumba de Keats, la rica cocina de casquería romana, la burocracia, la calle en la que apareció el cadáver de Aldo Moro, los papas, Berlusconi y sus emisarios, una iglesia en la que nadie quiere casarse, el fútbol, las conspiraciones masónicas, los palazos, la cúpula de San Pedro entre la neblina…",
    "year": 2015,
    "authors": [
      "Enric Gonzalez Torralba"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 257
  },
  {
    "title": "VAGABUNDO: UNA VUELTA AL MUNDO EN BICI",
    "isbn": "9788466656238",
    "synopsis": "Una travesía durante la cual el autor recorrió 36 países a lo largo de 40.000 kilómetros pedaleando durante más de 400 días. Xavi Narro tiene todo lo que necesita para ser feliz. Sin embargo, no se puede quitar de la cabeza la estúpida promesa que, de pequeño, se hizo a sí mismo: \"Cuando cumpla los treinta, dare la vuelta al mundo en bicicleta.\" Inevitablemente, ese día llega, y Xavi se ve obligado a abandonar lo que hasta el momento ha sido su vida para ponerse a pedalear por todo el planeta durante quince meses. A lo largo de cuarenta mil kilómetros topará con personajes tan pintorescos como su propio fantasma, un pingüino en un lavabo y la duquesa de Alba de luna de miel. Al mismo tiempo, nos hará reír, llorar y reflexionar sobre la importancia de seguir nuestro propio camino, aunque este desemboque en un precipicio.",
    "year": 2015,
    "authors": [
      "Xavi Narro"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 258
  },
  {
    "title": "EL LARGO VIAJE",
    "isbn": "9788426145963",
    "synopsis": "En 1968 el periódico The Sunday Times de Londres, propuso organizar una regata en solitario y sin escalas alrededor del mundo a un grupo de navegantes entre los que se encontraba Bernard Moitessier. Nunca se había hecho nada parecido. Aquí se inició la insólita historia que se narra en este libro: 37.000 millas marinas para llegar? al corazón de un hombre. Esta nueva edición incluye un inestimable prólogo de Julio Villar, quien compartió escala (y muchas cosas más) con Moitessier en este largo viaje. El largo viaje es el relato de diez meses navegando en solitario. El periplo significó una vuelta y media al mundo a través del mar, que, «según el viento, según el cielo, según que el ocaso fuera rojo o gris, ruge, murmura o gime bajo el casco».",
    "year": 2022,
    "authors": [
      "Bernard Moitessier"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 268
  },
  {
    "title": "HUELLA JONDA DEL HEROE",
    "isbn": "9788412272062",
    "synopsis": "La magia del lugar y del tiempo, del ser y del estar. Fiel a su estilo inclasificable, Montero Glez traza en estas páginas un delicioso libro de viajes físico y temporal a lo largo y ancho de un Sur emocional. Con una prosa rica y ágil, combina elementos tan dispares como inesperados: Cádiz, Hércules, Camarón de la Isla, Tánger, Quiñones, Sevilla, Kiko Veneno, los monos de Gibraltar, Ceesepe, la Venta de Vargas y del Ventorrillo, Paul Bowles, Rancapino, la grifa, Caracol, García Lorca? Esta obra fue galardonada con el Premio Llanes de Viajes 2012, y una década después la recuperamos, en una edición revisada por el autor y con un prologuista de excepción. En ella, Glez propone un viaje hacia parajes emocionales inesperados, rebosantes de música e imágenes luminosas.",
    "year": 2021,
    "authors": [
      "Montero Glez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 274
  },
  {
    "title": "BAJO LA MIRADA DEL DRAGON DESPIERTO",
    "isbn": "9788401026164",
    "synopsis": "Mavi Doñate, corresponsal deRTVE en Pekín, nos ofrece un libro imprescindible para entender la transformación del mundo global.«Bajo la mirada del dragón despierto es tan solo una de mis crónicas, contada en primera persona, sobre la cobertura periodística que jamás habría querido hacer, pero que, de seguro, ha sido y será la más importante de mi carrera».China está lejos. Es lo primero que aprende un periodista destinado en un extremo del mundo al que nunca hemos prestado demasiada atención. Cuando Mavi Doñate llegó a Pekín en elverano de 2015con el vértigo anidado en el estómago, cumplió un sueño que la había acompañado desde niña: ser corresponsal. Lo que no podía imaginar entonces es que estaba a punto de protagonizar una de las etapas de mayor intensidad informativa de este primer tramo de siglo.Mavi Doñate posee un don innato, mezcla de intuición y sutileza, para contar historias.",
    "year": 2022,
    "authors": [
      "Mavi Doñate"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 275
  },
  {
    "title": "UN VIAJE POR LA RAYA",
    "isbn": "9788494976001",
    "synopsis": "YA EN 3ª EDICIÓN. El libro definitivo de uno de los mayores especialistas en la Raya, donde se describe el primer recorrido completo por la frontera hispano-portuguesa, población a población, desde Ayamonte hasta Caminha. Con un extenso y profundo epílogo del acreditado historiador César Rina y amplio reportaje gráfico de Esperanza Rubio.YA EN 3ª EDICIÓN. El libro definitivo de uno de los mayores especialistas en la Raya, donde se describe el primer recorrido completo por la frontera hispano-portuguesa, población a población, desde Ayamonte hasta Caminha. Con un extenso y profundo epílogo del acreditado historiador César Rina y amplio reportaje gráfico de Esperanza Rubio.Este itinerario completo por las dos caras de un mismo límite, el que separa España y Portugal, ofrece una nueva visión sobre la cicatriz de la Península Ibérica, un continuo gozne territorial tan inactual como profundamente rico.",
    "year": 2021,
    "authors": [
      "Jose Ramon Alonso de la Torre"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 284
  },
  {
    "title": "EL CANINO DE SANTIAGO",
    "isbn": "9788412323252",
    "synopsis": "Ven. Acércate. Este es un libro para todos los públicos lleno de amor y humor. Es un manual de emociones. Es una oda al amor y la unión perro-humano y, al mismo tiempo, es una puesta en valor de que lo importante de la vida es vivirla cada día. Como bien te recuerda y enseña el Camino de Santiago: lo importante de cualquier camino es el propio camino, no la meta.En el interior encontrarás una doble aventura: la del primer Camino De Santiago que hicieron Nala y Sara, y la del camino de su vida juntas, como pack vital.",
    "year": 2021,
    "authors": [
      "Sara Escudero Rodriguez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 291
  },
  {
    "title": "PASAPORTE SENTIMENTAL",
    "isbn": "9788418800191",
    "synopsis": "Un sugerente catálogo de pequeños placeres y momentos maravillosos.En Pasaporte sentimental Arturo San Agustín lleva al lector a las cuatro esquinas del mundo, en una suerte de colección de postales, recuerdos, sensaciones y momentos imperecederos donde lo vivido se confunde con lo leído, y lo leído con lo vivido. De una ciudad a otra, de un recuerdo a otro. Del silencio atronador de la noche africana a Torshaven, cuyo puerto rinde homenaje a Thor, dios del Trueno. O del sillón de Hemingway a la nota reverberante del erhu, instrumento de origen chino.",
    "year": 2022,
    "authors": [
      "Arturo San Agustin"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 296
  },
  {
    "title": "VIAJE A LADAKH, EL PEQUEÑO TIBET",
    "isbn": "9788416783564",
    "synopsis": "\"Ladakh, región situada en la vertiente norte del Himalaya indio, posee un enorme atractivo para el viajero actual. A la belleza abrupta de sus inmensas montañas y valles se une la riqueza y originalidad de una cultura, la tibetana, conservada con una pureza difícil de hallar en el propio Tíbet central. La hospitalidad y simpatía de sus habitantes, todavía no contaminados por el turismo masivo, hacen del viaje una continua invitación al disfrute, al aprendizaje, a la reflexión.Marta Torres Santo Domingo nos lleva, con este libro, a una etapa más de su particular Ruta de la Seda. Con ella visitaremos Dharamsala y el sueño del exilio tibetano, cruzaremos la Gran Cordillera por el Rothang Pass con los moteros que hacen la «Manali-Leh Road» y nos dejaremos rodear por las cabras pashminas del altiplano tibetano. Llegaremos al valle del Indo, cuna del reino de Ladakh, y nos adentraremos en el misterio de sus monasterios budistas.",
    "year": 2018,
    "authors": [
      "Marta Torres Santo Domingo"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 306
  },
  {
    "title": "LOS CAMINOS DEL MUNDO",
    "isbn": "9788499427782",
    "synopsis": "Los caminos del mundo es un texto de culto para toda una generación de lectores de libros de viajes.«Un viaje no necesita motivos. Pronto demuestra que tiene sentido por sí mismo. Tú piensas que vas a hacer un viaje, pero muy pronto es el viaje quien te hace a ti. O quien te deshace.»En 1953, con solo veinticuatro años, Nicolas Bouvier emprende, junto al dibujante Thierry Vernet, un viaje por Yugoslavia, Grecia, Turquía, Irán y Pakistán a bordo de un diminuto Fiat Topolino. A lo largo de su expedición, que se alarga diecisiete meses, ambos recogen sus impresiones y experiencias—Bouvier las escribe y Vernet las ilustra—, en un intento de fijarlas y de retratar las costumbres de las gentes que habitan los diversos países por las que discurre su aventura, que tiene su punto y final en Afganistán.",
    "year": 2019,
    "authors": [
      "Nicolas Bouvier"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 310
  },
  {
    "title": "AMUNDSEN-SCOTT: DUELO EN LA ANTARTIDA",
    "isbn": "9788415174318",
    "synopsis": "El descubrimiento del Polo Sur es una historia trepidante, un desafío que protagonizaron el noruego Roald Amundsen y el inglés Robert F. Scott, una exploración que se convirtió en la que podríamos llamar la última gran aventura del ser humano, después de la llegada a la Luna. Amundsen viajó a la Antártida para ganar, Scott para morir, ambos para alcanzar la gloria.El experto en la Antártida Javier Cacho nos narra con todo lujo de detalles las peripecias de las expediciones de Amundsen y Scott, un duelo que ejemplifica la sempiterna gesta de la lucha entre el hombre y la naturaleza, donde el trofeo sería el lugar más recóndito de la Tierra, el punto más inaccesible, el paraje más peligroso: el Polo Sur. Y aunque ese desafío ya era suficiente en sí mismo, las circunstancias conspiraron para que la hazaña se convirtiera, además, en una competición, en una carrera, no sólo para alcanzar el Polo Sur, sino para ser los primeros.",
    "year": 2017,
    "authors": [
      "Javier Cacho Gomez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 313
  },
  {
    "title": "MI LONDRES",
    "isbn": "9788494426346",
    "synopsis": "Cuando Simonetta Agnello Hornby llegó por primera vez a Londres, en septiembre de 1963, tenía dieciocho años. Y desde entonces no ha abandonado la ciudad, salvo para pasar los veranos en su Sicilia natal. Este libro es un homenaje a su ciudad: es el Londres de Simonetta Agnello Hornby, el Londres tolerante y democrático que recibe a la gente de todas las etnias y le da la posibilidad de trabajar, el Londres que no para de crecer y está en constante movimiento, el Londres que palpita y sorprende, y siempre está dispuesto a ofrecer algo nuevo al visitante.",
    "year": 2015,
    "authors": [
      "Simonetta Agnello Hornby"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 315
  },
  {
    "title": "VIAJE A PIE / MAR DE NUBES",
    "isbn": "9788482166216",
    "synopsis": "Nueva edición aumentada de un clásico de los viajes por los Pirineos. La poesía de Julio Villar atrapa nuestro corazón con este relato intimista y personal de su viaje a lo largo de la cordillera pirenaica. A los textos de juventud, el autor a añadido en esta nueva edición Mar de Nubes, un relato escrito desde la perspectiva del paso de los años.",
    "year": 2016,
    "authors": [
      "Julio Villar"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 322
  },
  {
    "title": "AVILA (RUSTICA)",
    "isbn": "9788494445552",
    "synopsis": "La ciudad de Ávila y su provincia tienen uno de sus mejores relatos en esta obra.Dioniso Ridruejo (1912-1975), acometió con el may or entusiasmo su guía personalde Castilla la Vieja. De Ávila nos dice Ridruejo que «el tremendo legado de sucantera histórica es tan solo belleza».",
    "year": 2016,
    "authors": [
      "Dionisio Ridruejo"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 323
  },
  {
    "title": "DICTIONNAIRE AMOUREUX DE VENISE",
    "isbn": "9782259197199",
    "synopsis": "A. C.Couverture: ?? Venise est une grande aventure historique. Elle peut ??tre aussi une passion individuelle. C''est le cas ici. Dans ce titre : Dictionnaire amoureux de Venise, je souligne le mot amoureux. Il ne s''agit ??videmment pas d''un ??guide?? (il y en a d''excellents), mais d''une exp??rience personnelle li??e ?? ma vie d''??crivain. Je suis arriv?? l?? tr??s jeune, j''ai pass?? chaque ann??e, printemps et automne, beaucoup de temps ?? marcher, naviguer, regarder, respirer, dormir et m''??merveiller. Venise, voil?? son secret, est un amplificateur. Si vous ??tes heureux, vous le serez dix fois plus, malheureux, cent fois davantage. Tout d??pend de votre disposition int??rieure et de votre rapport ?? l''amour. L''amour ? Oui, et dans tous les sens : anges et libertinage, architecture, peinture, musique, roman, po??sie, mais aussi air, pierre, eau, ??toiles. Nature et culture enfin ?? ??galit??.",
    "year": 2004,
    "authors": [
      "Philippe Sollers"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 343
  },
  {
    "title": "NO HABLARAS MI LENGUA",
    "isbn": "9789871758180",
    "synopsis": "\"Este libro de Abdelfattah Kilito es una mezcla de ensayo y de cuento; pero si alguien me preguntara por su contenido, yo le diría que es un libro de viajes.Sí, un libro de viajes en el más amplio sentido de la expresión, pues el autor nos lleva de la Edad Media a nuestros días, de Marruecos a China. Y ahí reside gran parte de la amenidad del libro: Averroes, Al-Yáhidh, Ibn Batuta, Muhammad Saf-fár, Al-Fariáq, Shidiáq... Todos ellos se pasean por sus páginas, intentando comprender al otro, a los europeos o a los chinos, y chocando siempre con la barrera de la lengua y de la cultura... un relato ameno, en el que es inevitable el recuerdo de Borges, pues siempre hay una sorpresa que aguarda al lector\".Del Prólogo de Carlos Alvar",
    "year": 2012,
    "authors": [
      "Abdelfattah Kilito"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1287
  },
  {
    "title": "VIAJE A LAS ISLAS CANARIAS",
    "isbn": "9788403512863",
    "synopsis": "El escritor y periodista Juan Cruz regresa a su tierra, las islas Canarias, para compartirla con los lectores. Este es uno de los libros m#s personales de Juan Cruz, unas p#ginas que no constituyen unas memorias ni una gu#a tur#stica al uso, sino que son el relato de un viaje sentimental, tejido de lecturas, recuerdos y experiencias, a la esencia misma de las islas Canarias y sus gentes. Viaje a las islas Canarias es una fusi#n de literatura y viaje que cautivar# tanto a los trotamundos como a los que disfrutan con una buena lectura. Una prosa viva y evocadora, y la ocasi#n de descubrir nuevos lugares, o revivir los ya visitados, a trav#s de la visi#n personal de un autor de prestigio. Incluye escritos, an#cdotas y comentarios de personalidades que tuvieron relaci#n con las islas: Ignacio Aldecoa, Unamuno, Humboldt, Garc#a M#rquez, Chillida, C#sar Manrique...",
    "year": 2013,
    "authors": [
      "Juan Cruz Ruiz"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1298
  },
  {
    "title": "LA SENDA MANUSCRITA. RUTAS POR LA ESPAÑA HISTORICA, LENGENDARIA Y MISTERIOSA.",
    "isbn": "9788493866525",
    "synopsis": "¿Sabías que el abuelo de Europa se encuentra en la Península Ibérica? ¿Pudo estar la Atlántida en el suroeste andaluz? ¿Cuántos tesoros de la Cristiandad se esconden en nuestra geografía? ¿Qué secretos ocultan nuestros pueblos? ¿Qué parte de los mitos deberíamos tomarnos en serio?La historia de nuestro mundo va unida, inevitablemente, a la acción de los caminos.De la Prehistoria y las primeras civilizaciones a la Edad Contemporánea son incontables los kilómetros recorridos en busca del equilibrio entre el ser humano y su entorno: itinerarios de conquista, peregrinaciones espirituales o travesías inciertas, siempre atrayentes pero a la vez repletas de peligros, giros inesperados y, sobre todo, muchas sorpresas.Por ello te invitamos a enrolarte en un viaje por la España más inédita y deslumbrante; aquella donde lo histórico va flanqueado por el hechizo de la leyenda y el misterio.",
    "year": 2012,
    "authors": [
      "Antonio Puente Mayor"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1312
  },
  {
    "title": "EL BORSALINO NEGRO",
    "isbn": "9788493980955",
    "synopsis": "Jonás es un periodista de mala reputación afincado en Madrid. Jonás es el que viaja por mediación de su benefactora a Estambul para escribir artículos sobre un político eminente de la antigua Turquía. Jonás es el que una vez allí se enreda en una historia en la que arriesgará su vida y la de sus acompañantes para salvar al pequeño Kamal de su cruel perseguidor. El Estambul moderno, de Chanel y mezquitas ancestrales, intercalado en el Madrid bohemio y canallesco de Sabina, Antonio Vega, Aute, más la rancia aristocracia madrileña de taberna y palacios de cristal. Vivísima historia narrada en primera persona que combina la acción vibrante con el libro de viajes, el estilo duro e impecable con una historia de amor y muerte que engancha al lector desde el primer momento.",
    "year": 2012,
    "authors": [
      "Arturo Suarez-Barcena Bombin"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1327
  },
  {
    "title": "PALABRAS DE INVIERNO",
    "isbn": "9788494080418",
    "synopsis": "“Palabras de invierno” es un libro de relatos en el que esta estación acompaña y envuelve. El invierno es una época, como dice el autor, absolutamente literaria. Es la época en la que el libro es el mejor compañero. Parece como si el silencio y el frío, asociados siempre en nuestras latitudes al tiempo invernal, empujaran a leer. Despacio, degustando cada página, cada pequeña aventura, cada pensamiento. Juan Manuel Agudo es un escritor imaginativo, que vive profundamente lo que escribe. Viaja en sus líneas escritas como un descubridor de los pequeños mundos en los que habitan sus personajes, en los que habita él mismo. Estas palabras invernales son una pequeña delicia para leer en la única estación que, como él también dice, cabalga siempre entre dos años diferentes, en el final de uno y el comienzo de otro.",
    "year": 2013,
    "authors": [
      "Juan Manuel Agudo"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1329
  },
  {
    "title": "EL PERU POR DENTRO",
    "isbn": "9788497168120",
    "synopsis": "Este libro, fruto de una larga e intensa experiencia personal y de un profundo conocimiento del país, ofrece un panorama resumido pero muy completo de la realidad peruana (geografía, cultura, historia, grupos humanos, la tradición y el presente), con el deseo de contribuir a dar a conocer este gran país y su gente y de servir de guía -de gran interés y utilidad- para el viajero.",
    "year": 2013,
    "authors": [
      "M Del Carmen Valades"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1343
  },
  {
    "title": "VIAJES DE UN DESMEMORIADO",
    "isbn": "9788415415305",
    "synopsis": "«La literatura de viajes de Benito Pérez Galdós representa las sensaciones del viajero y las ideas sobre lo visto, mezclado con sus percepciones individuales, en una prosa de carácter impresionista. El viaje, hecho cada vez en medios de locomoción más veloces, exigía una innovadora forma de expresar el paso de las imágenes, del paisaje visto a través de una ventanilla, del tren o del automóvil. »Los textos recogidos en este volumen merecen ser leídos para complementar sus novelas y para entender los gustos y observaciones personales de este hombre tan enigmático y reservado, un gran observador de la vida. No son relatos de turista sino de auténtico viajero, del hombre paciente que sabe encontrar matices y diferencias y quiere conocer las costumbres de los sitios visitados.",
    "year": 2012,
    "authors": [
      "Benito Perez Galdos"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1347
  },
  {
    "title": "MISTER JOHNSON",
    "isbn": "9788415374350",
    "synopsis": "Míster Johnson, un joven empleado africano del puesto colonial de Fada, en Nigeria, lleva una vida feliz. Ha conocido a Bamu, la muchacha más hermosa del lugar, y su empleo para la administración colonial le confiere un estatus privilegiado. Y aunque la comunidad indígena y la administración británica se confabulen contra él -las deudas lo acosan y sus jefes lo hostigan- nada podrán contra su felicidad.",
    "year": 2012,
    "authors": [
      "Joyce Cary"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1375
  },
  {
    "title": "SALI A DAR UNA VUELTA (+ CD INTERACTIVO)",
    "isbn": "9788461598953",
    "synopsis": "¡Fabián se ha vuelto loco! Ha decidido cerrar su empresa, montarse en una moto grande como un tractor y dar la vuelta al mundo durante dos años recorriendo sesenta países. Luego, ya se verá. A ambos lados de la carretera, el intrépido Fabián y la infatigable moto Fefa se encontrarán un mundo en crisis pero hermoso, lleno de contrastes, en el que hay espacio para paisajes inolvidables, seres crepusculares, rostros irrepetibles, gentes generosas, pobres de solemnidad, cielos infinitos y dos o tres encontronazos con la Interpol y las moscas de la caca.Con una prosa elegante, hipnótica, mordaz en ocasiones, trepidante en otras, Salí a dar una vuelta es un libro imprescindible para todos aquellos que un día pensaron en dejarlo todo y montar un chiringuito en la playa, para los apasionados de los viajes y en especial para los amantes de las dos ruedas.Incluye un CD interactivo con más de 1400 fotos comentadas por el propio autor.",
    "year": 2012,
    "authors": [
      "Fabian C. Barrio"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1376
  },
  {
    "title": "A LA PATAGONIA",
    "isbn": "9788493945862",
    "synopsis": "El desembre de 1974 Bruce Chatwin envia des de Lima una carta al seu cap del Sunday Times: «He complert la meva amenaça. De repent mhe atipat de Nova York i he fugit a Sudamèrica [ ]La meva intenció és passar el Nadal en plena Patagònia. Treballo en una relat propi, una cosa que sempre he volgut escriure.»A la Patagònia és el resultat dels mesos que Chatwin hi va passar viatjant. Construït com un seguit dinstantànies (Chatwin era un gran aficionat a la fotografia), lautor teixeix una història plena de paisatges i figures que es mouen entre el mite i la realitat. Apassionat dels viatges a peu Chatwin, va aconseguir amb aquest llibre publicat el 1977 convertir-se en un referent indispensable de la literatura de viatges.",
    "year": 2012,
    "authors": [
      "Bruce Chatwin"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1394
  },
  {
    "title": "LA CASA DE VAPOR",
    "isbn": "9788415374336",
    "synopsis": "En mayo de 1867 un grupo de hombres ( el coronel Munro, su asistente el sargento McNeil, el ingeniero Banks, el capitán Hod y el señor Maucler, narrador de la historia) realizan un viaje a través de la India en un fantástico medio de transporte: un vehículo con tracción a vapor acondicionado como vivienda. Parten de Calcuta en dirección a Benarés y luego al norte para alcanzar las laderas del Himalaya. El coronel Munro tiene un enemigo mortal, Nana Sahib, el único líder de la rebelión de los cipayos que permanece todavía con vida, responsable de la muerte de varios centenares de mujeres y niños, entre los cuales se encuentra la propia lady Munro. La aventura de esta enemistad y las peripecias del viaje, del que la caza del tigre de bengala es uno de los principales objetivos, constituyen esta espléndida novela, cuya traducción es de una alta calidad literaria.",
    "year": 2012,
    "authors": [
      "Julio Verne"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1396
  },
  {
    "title": "60.000 MILLAS A VELA",
    "isbn": "9788474862027",
    "synopsis": "Bernard Moitessier fue un extraordinario navegante dotado de una profunda espiritualidad, un filósofo de la aventura y la naturaleza, que llegó a convertirse en un auténtico mito. Pero, ¿quién puede hablar de él mejor que alguien que ha compartido su vida, sus viajes y sus ilusiones? Françoise Moitessier, su mujer, nos cuenta sus recuerdos. Los que aun no le conocen podrán saber quién fue, también descubrirán que Françoise, en lugar de refugiarse bajo la sombra de su ilustre marido, ha sabido gobernar su barco contotal independencia: navegante solitario, heroína de múltiples aventuras náuticas, nos cuenta con una pluma ágil las penas y alegrías de una mujer que ha recorrido 60.000 millas a vela.",
    "year": 2009,
    "authors": [
      "Françoise Moitessier"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1423
  },
  {
    "title": "EL DIENTE DE LA BALLENA: TRES VIAJES NOMADAS A LOS CONFINES DE AM ERICA, AFRICA Y ASIA",
    "isbn": "9788493904401",
    "synopsis": "El Diente de la Ballena fue publicado por primera vez en 1999. Se trataba de un texto que seguía la senda de los dos grandes maestros de la literatura de viajes contemporánea en España: Manu Leguineche y Javier Reverte. Un relato, o mejor dicho, tres relatos cargados de empatía y sentido del humor, un recorrido por tres continentes, América, África y Asia, en los que el viajero nos conduce hasta algunos de los lugares más remotos de la Tierra al encuentro de sí mismo, a la búsqueda de un paraíso que no existe. Chema Rodríguez (Sevilla, 1967) es escritor y director de cine. Ha publicado los libros El Diente de la Ballena, El País-Aguilar (1999) y Anochece en la India, RBA (2003)",
    "year": 2011,
    "authors": [
      "Chema Rodriguez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1431
  },
  {
    "title": "LA EMOCION DEL NOMADA",
    "isbn": "9788415097617",
    "synopsis": "Tras la publicación de Un millón de piedras, Miquel Silvestre se embarca ahora en una nueva aventura, desde Europa hasta Asia Central para llegar luego a Tierra Santa, a modo de peregrinaje iniciático a lomos de una moto.Viajar en moto no es siempre rodar y rodar, moverse libre, born to be wild. A veces, la moto se convierte en una bola de presidiario que consume toda la energía, que se estropea, se accidenta... y hay que saltar un océano o cruzar una frontera. Miquel Silvestre no se considera un héroe pero viaja para parecerse a uno de verdad, para vivir una épica real a pesar de los miedos y las limitaciones. La emoción del nómada queda recogida en este diario de viaje lleno de peripecias, de modo directo y sin adornos. La realidad ya es suficientemente surrealista como para inventar nada.",
    "year": 2013,
    "authors": [
      "Miquel Silvestre"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1447
  },
  {
    "title": "VIAJES SIN MAPA",
    "isbn": "9788497734134",
    "synopsis": "Manuel Cuenya narra a través de 162 páginas sus aventuras por ciudades como El Cairo, Marrakech, Lisboa, París, Cracovia o La Habana. Sobre la obra Esther Folgueral ha escrito: En este libro de viajes encontramos información, datos útiles, fotografías, pero también el pensamiento del viajero, que resalta la dulzura que le embarga en Lisboa o Marrakech, así como la desazón del París que descubre más allá de sus apariencias.",
    "year": 2008,
    "authors": [
      "Manuel Cuenya"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1484
  },
  {
    "title": "MANUAL PARA VIAJEROS POR LEON Y LECTORES EN CASA",
    "isbn": "9788475060569",
    "synopsis": "El Manual de viajeros por Leon constituye una entrega más de la edición completa del famoso manual de Ford, publicado por primera vez en 1845. Bajo el discreto título de ''Manual'' se sconde el más completo, más original, más profundo y mejor escrito entre los numerosos libros producidos por los viajeros románticos.",
    "year": 1983,
    "authors": [
      "Richard Ford"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1534
  },
  {
    "title": "MENORCA, SENCILLAMENTE FASCINANTE",
    "isbn": "9788461327256",
    "synopsis": "\"Menorca es un paraíso de bolsillo, un lugar repleto de bellísimos rincones, que sorprende continuamente al visitante con la variedad de su paisaje. La isla parece estar dividida en dos, el norte, árido, ocre, con un paisaje barrido por el viento, pizarra y arcilla, y el sur, roca caliza, pinos que aparentan brotar del mismo mar, y calas de arena blanquísima. Pero «la isla del viento» tiene algo más y es que parece siempre envuelta por un halo de misterio. Quienes hemos estado allí, lejos de los complejos turísticos, conocemos esa sensación que comienza en la planta de los pies como un cosquilleo de inminente aventura. Todo aquel que quiera vivir una serie de sucesos extraordinarios y recuperar la mirada de la juventud que lea este libro, inmediatamente después no hará otra cosa más que desear coger un avión.\"",
    "year": 2009,
    "authors": [
      "Margarita de Los Angeles Monjo"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1548
  },
  {
    "title": "DE PARIS A BARCELONA PASANDO POR HONOLULU (1927-1928)",
    "isbn": "9788493706258",
    "synopsis": "\"The Largest Ship to Circle the Globe Esta fue la frase ideada en el año 1924 por los publicistas de la compañía Red Star para promocionar su producto estrella, un viaje de circunnavegación mundial a bordo de un crucero de lujo, el Belgenland, una experiencia al alcance de muy pocos que un barcelonés, Joan Marín y Balmas, tuvo la fortuna de vivir. También tuvo el acierto de narrar su aventura con un lenguaje fresco y sencillo, no exento de elegancia, que ochenta años después llega a nosotros en esta nueva edición. Cuando Marín embarcó, en 1927, los felices años veinte se aproximaban a su traumático fin, pero aún tuvo la oportunidad de vivir aquel ambiente con todo su esplendor, integrado en un selecto pasaje de millonarios norteamericanos, entregados a costumbres sofisticadas y cosmopolitas.",
    "year": 2009,
    "authors": [
      "Joan M. Marin"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1549
  },
  {
    "title": "UNA GRANJA DE L AMAZONIA",
    "isbn": "9788497914185",
    "synopsis": "_Una granja a l''Amazònia_ ens descriu, sobretot, l''experiència de tirar endavant una granja enmig de la selva amb respecte per l''entorn, alhora que ens fa partícips de la quotidianitat d''un autèntic habitant d''aquest medi natural; un recull d''experiències en un món poc domesticat, un món de frontera, encara ben independent de la voluntat i la manera de fer dels homes.",
    "year": 2009,
    "authors": [
      "Carles Santasusagna"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1558
  },
  {
    "title": "ASANTE AFRICA: CRONICA DE UN ENCUENTRO CON LOS PUEBLOS DE SUDAFRI CA, SUAZILANDIA, TANZANIA Y KENIA",
    "isbn": "9788482984759",
    "synopsis": "Témoris Grecko tiene la mirada de un viajero con capacidad de sorpresa y de un igual que busca amistades locales. A veces nos divierte con buen humor y otras nos habla con profundidad periodística. Nos comunica el lado duro de África, ése que conocemos por tantos reportajes de telediario de dos minutos, pero sobre todo, nos presenta con quienes están esforzándose por cambiar su realidad, nos pone en contacto cercano con personas como nosotros que dan ejemplos de valor sin darse cuenta de ello.",
    "year": 2009,
    "authors": [
      "Temoris Grecko"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1560
  },
  {
    "title": "LA ULTIMA CENA",
    "isbn": "9788426417312",
    "synopsis": "Con la excusa de narrar su estancia familiar de tres meses en la Toscana, la escritora inglesa Rachel Cusk nos ofrece la crónica de un viaje interior que pone en tela de juicio su formación e incluso su misma identidad. En medio de la campiña, el arte, la gente y la cocina de la región, Cusk teje un relato íntimo sobre su propia evolución sentimental. Con el virtuosismo estilístico, la perspicacia y la desnuda inteligencia de sus novelas, Cusk consigue renovar el estricto género de la literatura de viajes.",
    "year": 2009,
    "authors": [
      "Rachel Cusk"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1563
  },
  {
    "title": "NOTES DEL CAPVESPROL (2ª ED.)",
    "isbn": "9788423309788",
    "synopsis": "Por varias razones, fracasa el proyecto literario con la editorial Selecta. Después de unos años sin editor, Pla firma un contrato en exclusiva con la editorial Destino, dirigida por Josep Vergés, de Palafrugell, para poder editar una nueva versión de la obra completa. El primer tomo es un libro inédito: El quadern gris, verdadera síntesis de toda la obra planiana. Después, llegarán otros libros inéditos, narraciones autobiográficas, libros de viajes reelaborados, recopilación de artículos, etc. El reconocimiento de la nueva obra completa por parte de la crítica tan sólo es el reflejo del apoyo incondicional de miles y miles de lectores de todas las generaciones, de todas las ideologías y todos los países catalanes que, como mínimo desde 1925, habían seguido con un verdadero entusiasmo la evolución de su obra.",
    "year": 1994,
    "authors": [
      "Josep Pla"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1569
  },
  {
    "title": "KANGCHENJUNGA (2ª ED.)",
    "isbn": "9788426118486",
    "synopsis": "El Kangchenjunga es el centro y el punto más elevado de una estribación dela cadena principal del Himalaya. La estribación se adentra hacia el Sur, dominando las llanuras de la India. Durante estos últimos años han sido escalados los picos más altos del mundo. El Kangchenjunga es uno de ellos. Varios intentos para llegar a su cima, iniciados en el siglo XIX y proseguidos en 1905, 1920, 1929, 1940, etc., no llegaron a su feliz término. Pero en 1955, un grupo de especialistas en escalada preparó cuidadosamente otra expedición que, por consejo de Sir John Hunt, jefe del grupo que coronó el Everest en 1953, fue patrocinada por el Club Alpino y la Real Sociedad Geográfica. Charles Evans relata con brillante estilo las dificultades de la azarosa aventura. En su tarea se ha valido de los diarios de sus compañeros.",
    "year": 1981,
    "authors": [
      "Charles Evans"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1572
  },
  {
    "title": "LIBRO DEL CAMINO DE SANTIAGO",
    "isbn": "9788496822979",
    "synopsis": "Un extremo de España atrae a los hombres y desprende su fulgor. Santos, bandidos y violadores, aristócratas y siervos, reinas y amas de casa…, multitudes de solitarios, cada uno con su verdad y su culpa como fardo. Pero el Camino, peaje de penitencias, da también ocasión para la holganza y la aventura, la culpa se torna gozo. Bajó Santiago a la Tierra por el camino de leche hasta Compostela, en los finisterres atlánticos, allá donde muere el sol, donde quizá esté la entrada del infierno. Y detrás de su leyenda van los peregrinos, seducidos por el misterio de lo que han de encontrar.o por la saludable caminata.",
    "year": 2010,
    "authors": [
      "Xose Miranda Ruiz"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1593
  },
  {
    "title": "ASTURIAS PARA VERA",
    "isbn": "9788496715387",
    "synopsis": "Estos viajes por Asturias no sólo atienden a los espacios físicos, sino también a los simbólicos, resumidos en la figura de un observador que es a la vez padre y escritor. De ese modo, en el continente de este libro conviven determinados aspectos del territorio (la costa asturiana, uno de los itinerarios más conspicuos del salmón, las huellas de los artes prerrománico y románico o el universo del pan en un concejo del occidente interior) con distintos motivos, recogidos bajo el rótulo digresiones, que operan como una suerte de cajón de sastre para la reflexión y el debate (el Carnaval, los paraísos de la infancia, la evidencia de la inmigración y una mirada tangencial a dos de los elementos centrales de la constelación minera: la vivienda y la conciencia política).",
    "year": 2010,
    "authors": [
      "Ricardo Menendez Salmon"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1597
  },
  {
    "title": "VIAJE AL CONGO",
    "isbn": "9788499420080",
    "synopsis": "Pilar de la narrativa francesa de la primera mitad del siglo XX, Gide es toda una literatura. Su talento y su agudeza para la observación han hecho de sus obras una referencia obligada para lectores de varias generaciones. Habitante actual del purgatorio de los escritores, su prosa, sin embargo, merece salir del olvido y encabezar la lista de escritores que han aportado una visión radical (moral) del mundo. Este Viaje al Congo que ahora proponemos, es una excelente oportunidad para (re)descubrir a Gide. Un escritor que comprendió, viajando, viviendo, sufriendo y amando, la importancia del punto de vista. Miremos a traves de Gide. Un autor, imprescindible, que nunca decepciona.Los editores",
    "year": 2010,
    "authors": [
      "Andre Gide"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1601
  },
  {
    "title": "AFRICA !A SANGRE Y FUEGO!",
    "isbn": "9788498865370",
    "synopsis": "Antonio D. Olano cuenta en este libro sus viajes al África, relatando la situación política de los países, la forma de vida de las gentes que los habitan, sus costumbres, la participación de otros países en su desarrollo e incluso cosas puramente anecdóticas. Los relatos están enfocados desde un punto de vista periodísticos y son de variados temas, desde la independencia de los Congos ex-belga y ex-francés hasta los safaris, destacando lo dura que es la vida en la selva para las tribus que en ella viven. Resalta también la emoción, calamidades y peligros que se corren en una tierra como es el África negra.",
    "year": 2014,
    "authors": [
      "Antonio D. Olano"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1619
  },
  {
    "title": "DIARIOS DE BICICLETA",
    "isbn": "9788439723271",
    "synopsis": "David Byrne relata la crónica de sus experiencias, observaciones e impresiones al atravesar diferentes ciudades del globo a pedales. Un viaje directo al buen humor.Hace aproximadamente dos décadas David Byrne descubrió la bicicleta plegable y comenzó a utilizarla en sus viajes alrededor del mundo. Con un nuevo punto de vista, desde el sillín de su bicicleta, nació la vista panorámica de la vida urbana, una manera mágica de abrirle los ojos a los ritmos y secretos de las ciudades. En lugares como Buenos Aires, Estambul, San Francisco y Londres, el foco se dirige sobre todo hacia el gremio de músicos y artistas, mientras que en Berlín o Manila se interesa por cuestiones políticas.A lo largo del camino, David Byrne reflexionará sobre temas diversos: la globalización, la moda, la arquitectura, la soledad o los cambios radicales que están sufriendo algunas ciudades.",
    "year": 2010,
    "authors": [
      "David Byrne"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1630
  },
  {
    "title": "EL VIAJE POR ARAGON DE DON ANTONIO PONZ",
    "isbn": "9788499111001",
    "synopsis": "Este análisis del relato elaborado por el erudito y viajero valenciano Antonio Ponz en su recorrido por las tierras aragonesas durante los años 80 del siglo XVIII se propone examinar las intenciones del autor y las circunstancias concretas de esta región durante el período de la Ilustración.",
    "year": 2011,
    "authors": [
      "Jose Laborda Yneva"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1640
  },
  {
    "title": "A CIEN MILLAS DE MANHATTAN",
    "isbn": "9788403101418",
    "synopsis": "A cien millas de Manhattan John Raucci toma aire, aprieta los cordones de sus zapatillas y se dispone para la carrera sin saber que no será ésta la más dura de su vidaA cien millas de Manhattan Steve Mosto, músico de vocación, se prepara para adentrarse como cada mañana desde hace más de veinte años en los dominios del vapor, en el subsuelo de la Gran Manzana. A cien millas de Manhattan el paso de las estaciones acompaña la pesca del salmón, el rumiar de los bisontes en las inmensas praderas, la voz poderosa de los osos, las barbacoas al aire libre, las calabazas de Halloween. El olor de la madera y la melodía del hacha sobre el tronco del arce centenario intensifican el ritual de la recogida del sirope. A cien millas de Manhattan permanece aún el recuerdo de miles de esclavos que siglos atrás aprovecharon el silencio de la noche para lanzarse a una odisea en busca de la libertad.",
    "year": 2010,
    "authors": [
      "Guillermo Fesser"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1642
  },
  {
    "title": "VIAJE ALREDEDOR DEL MUNDO, SIGUIENDO EL ECUADOR T.1: LA TRAVESIA DEL PACIFICO",
    "isbn": "9788475842042",
    "synopsis": "El autor recorre en La travesía del Pacífico (primera entrega de su viaje), las islas Fidji, Nueva Zelanda y Australia, y con su visión humorística describe con sencillez y melancolía, pero también con ironía punzante los hábitos y costumbres de los nativos y colonizadores del siglo XIX en las por aquel entonces colonias o áreas de influencia inglesa.En India (segunda entrega de su viaje), el autor recorre Ceilán y todo el subcontinente indio colonial, incluyendo las áreas que con el tiempo devendrán las futuras naciones de Pakistán y Afganistán.En el tercer volumen de Viaje alrededor del mundo, siguiendo el Ecuador, Twain llega a Suráfrica tras haber recorrido las islas del pacífico, visitado Nueva Zelanda, Australia e India. Sus descripciones de un territorio donde se enfrentan ingleses, Boers y zulúes, y de sus costumbres, están llenas de ironía.",
    "year": 1992,
    "authors": [
      "Mark Twain"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1699
  },
  {
    "title": "HIJOS DEL FIN DEL MUNDO",
    "isbn": "9788496715288",
    "synopsis": "Este es un libro de infancia, y un libro de viajes, y un libro de historias recuperadas. Un libro para quienes se han regresado para contarlo, para quienes reconocen en su carne la misma materia que las estrellas y se saben de la misma constitución que los montes, los ríos, los animales y las plantas. Para quienes, como los antiguos habitantes de los bosques. de buena gana pedirían perdón al árbol que cortan, a los sentimientos que hieren, al tiempo que pasa y nos transforma en otra cosa. Esta es un libro que nace de un recuerdo, y de la imposibilidad de poseer una flor que, para colmo, nos mostraban ante los ojos constantemente, de la reconstrucción de un camino personal u un viaje que han seguido millones de personas, bajo de guía de las estrellas, sobre piedras milenarias y huesos blanqueados. Finisterre se adentra con su lengua de roca en el mar .",
    "year": 2009,
    "authors": [
      "Espido Freire"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1728
  },
  {
    "title": "FAROS: VIAJE ALREDEDOR DE ESCOCIA EN 1814",
    "isbn": "9789685115407",
    "synopsis": "Qué refrescante es leer un libro de impresiones de viaje cuando apenas se iniciaba, durante y tras el fracaso napoleónico, el turismo. Scott pensó que su periplo alrededor de Escocia en el año de 1814 era un viaje rápido, pero para nosotros, hombres de estos tiempos acelerados, su viaje conserva el candor de una edad que nunca ha de volver, justo antes de las revoluciones industriales. Las dos grandes virtudes de Scott en este libro son su amor, es decir su interés y su caridad por todo lo que ve, y su prosa de gran escritor que narra simplemente los hechos, apenas aquí y allá citando a algún latino (o a algún escocés). Este libro, a caballo entre un siglo que aún era como siempre habían sido y el siglo en el que todo iba a cambiar, es un libro muy notable. Y señero lo vuelve que hable de Escocia. Pablo Soler Frost (traductor y prologuista de la obra)",
    "year": 2009,
    "authors": [
      "Walter Scott"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1733
  },
  {
    "title": "HISTORIAS DE LONDRES",
    "isbn": "9788498677447",
    "synopsis": "Historias de Londres es una fascinante sucesión de crónicas del que fuera corresponsal del El País en la capital de Gran Bretaña. Una auténtica declaración de amor pudorosamente envuelta en ironía y humor donde el periodismo se convierte en herramienta para retratar a los personajes, las costumbres y los lugares de la City. Londres no teme a los cambios, ni teme a los extranjeros, ni teme perder una identidad determinada. Es de una indiferencia majestuosa ( )Northfields, South Ealing, Acton Town, Hammersmith ¡Qué hermosa sonoridad! Con nombres así, uno tiene ya medio hecha una novela de pasión en intriga . Picadilly Line: ya no se fabrican denominaciones tan elegantes para las líneas suburbanas. Incluso el vagón, estrecho y redondeado como un tubo, era una perfecta muestra del sentido común británico: ¿Para qué derrochar espacio y oxígeno? (Historias de Londres).",
    "year": 2010,
    "authors": [
      "Enric Gonzalez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1736
  },
  {
    "title": "ETIQUETAS: VIAJE POR EL MEDITERRANEO",
    "isbn": "9788490061312",
    "synopsis": "En 1929, el brillante y ácido escritor Evelyn Waugh tuvo la oportunidad de emprender un viaje a lo largo y ancho de todo el Mediterráneo, de Monte Carlo a Port Said, de El Cairo a Sevilla, pasando por ciudades como Nápoles, Constantinopla, Argel o Barcelona. Waugh, por entonces un valor emergente de la literatura inglesa, quiso dejar testimonio escrito de esta odisea. Sin embargo, como era consciente de lo poco original de sus destinos, se propuso dar una vuelta de tuerca a su relato y analizar los lugares y las personas que conoció adoptando una postura diferente, ingeniosa y muy, muy británica, que ya se adivina en el curioso título de este libro de viajes, «porque todos los lugares que visité durante mi viaje ya están perfectamente etiquetados».",
    "year": 2011,
    "authors": [
      "Sara Walden"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1787
  },
  {
    "title": "EMBAJADA A TAMERLAN",
    "isbn": "9788485639366",
    "synopsis": "Descripción del viaje (1403-1406) que por encargo del Rey Enrique III de Castilla realizó el autor a la mítica Samarcanda de Tamerlan, siendo éste el primer libro de viajes de la literatura castellana. La minuciosidad de las noticias y descripciones.",
    "year": 2019,
    "authors": [
      "Ruy Gonzalez de Clavijo"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1811
  },
  {
    "title": "DIARIOS Y TRABAJOS BOTANICOS DE LUIS NEE",
    "isbn": "9788477822394",
    "synopsis": "Esta colección publica y estudia los documentos más importantes y valiosos de la expedición Malaspina (1789-1798), la expedición marítima y científica más importante de la Ilustración española. El tercer volumen presenta los diarios y estudios botánicos realizados por Luis Nee durante la expedición de Malaspina. La aportación de este personaje a la botánica facilitó el trabajo de Antonio José Cavanilles (uno de los grandes botánicos españoles) y, mediante sus herbarios, puso a disposición de la comunidad científica las plantas desconocidas que recolectó durante su viaje.",
    "year": 1992,
    "authors": [
      "Felix Muñoz Garmendia"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1822
  },
  {
    "title": "EL CAMINANTE Y SU SOMBRA",
    "isbn": "9788498027341",
    "synopsis": "Se trata de un diario abierto y sincero que refleja con precisión las vivencias de un caminante, en todos los Caminos de Santiago recorridos, desde una perspectiva desenfadada aunque abundante en críticas y alegorías que presentan y representan el día a día de quienes viven y sufren a veces en solitario- los avatares propios de esta tentadora aventura, donde el azar y la improvisación ponen el resto. El autor se desprende aquí de todo tipo de formalismos y otras florituras para encarar de lleno, con osadía y desde su personal punto de vista, aunque con total objetividad, los pros y los contras, las alegrías y satisfacciones y también la otra cara de estos caminos legendarios, no exenta de contrariedades y decepciones, una conjugación que contrasta la magia y la realidad, tanto por causas de infraestructura como de los recursos humanos que en muchas ocasiones brillan por su ausencia.",
    "year": 2011,
    "authors": [
      "Francisco Nicolas Alacid"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1867
  },
  {
    "title": "LA VUELTA AL MUNDO DE UN NOVELISTA",
    "isbn": "9788415116462",
    "synopsis": "¿En qué consiste esta obra? Siendo simplistas diríamos que es un libro a caballo entre la biografía y el libro de viajes, pero si somos justos cabría matizar tanto como el saber enciclopédico que Blasco Ibáñez supo introducir de manera magistral entre estas páginas.Este es un doble viaje, geográfico y temporal, porque no solo cuenta su experiencia personal a bordo del Franconia, entre 1923 y 1924, sino que, con esa vocación de ilustrar, narra de dónde vienen los pueblos, en qué creen, como son las relaciones sociales de sus ciudadanos, tradiciones, leyendas.¿Quiénes llegaron primero a Hawai? ¿Cómo vivió Japón el desastre del terremoto de 1923? ¿Cómo vivían los indios un día de fiesta sacra en el Ganges?",
    "year": 2012,
    "authors": [
      "Vicente Blasco Ibañez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1929
  },
  {
    "title": "RECUERDOS DE ITALIA",
    "isbn": "9788496824522",
    "synopsis": "Conocedor de una extensa literatura sobre la materia, Emilio Castelar ofrece en Recuerdos de Italia la síntesis definitiva de su pensamiento y estilo. Sobre la emocionalidad impresionista de cuantas experiencias quedaron “grabadas en el corazón y en la memoria”, el autor realiza descripciones de monumentos y obras artísticas o de paisajes con “personalidad histórica”, apoyado en fecundas digresiones que son el fruto de su cultura enciclopédica. A caballo ente la nostalgia del desterrado y el optimismo de quien “ya tiene por patria la Europa redimida”, Castelar recorre la historia de la civilización ligada a la doble herencia, con sus luces y sus sombras, de Roma y el cristianismo. Las playas hermosísimas de Capri, la pintura de Miguel Ángel en la Sixtina o el cementerio de Pisa son algunos de los escenarios visitados por el escritor y político gaditano.",
    "year": 2009,
    "authors": [
      "Emilio Castelar"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1982
  },
  {
    "title": "NOVENTA Y DOS DIAS",
    "isbn": "9788415374329",
    "synopsis": "Tal vez la obra más importante de Taha Husein (1889-1973) sea su propia vida. Nacido en una familia modesta de Magaga, (Egipto Medio), séptimo de trece hermanos, con sólo tres años es tratado de una leve afección ocular por el barbero local, el cual le provoca definitivamente la ceguera. Debido a su aguda inteligencia y su extraordinaria memoria, pronto memoriza el Corán, y destaca de entre los alumnos de la escuela local (kuttab). Posteriormente es enviado a la gran escuela coránica de El Cairo: Al-Azhar. Allí vive el niño con un hermano mayor, que hace a desgana de lazarillo, y se introduce en la ciencia que tanto le intriga y tanto le fascina. En condiciones de extrema pobreza su vida discurre entre los corros de las lecciones de la mezquita y el rincón de su cuarto en el mísero caserón donde viven los estudiantes y poco a poco va renegando del sistema de enseñanza oscurantista y anclado en el pasado.",
    "year": 2012,
    "authors": [
      "Evelyn Waugh"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2071
  },
  {
    "title": "MARRAKECH (FRANCES Y ESPAÑOL)",
    "isbn": "9783943254136",
    "synopsis": "\"La grande avenue que le taxi venait de quitter était un modéle d''ordre en comparaison avec ce qui s''offait maintenant au regard de Celia: cyclistes, scoooters, piétons et voitures à bras allaient et venaient e tous sens avant de disparaître dans des ruelles encombrées, flanquées de petit immeubles rouge-brun et conduisant vers l''inconnu.\"Celia a finalement compris qu''elle nne serait jamais une grande star hollywoodiense quand son agent lui a signifié qu''il n''aurait plus de rôle por elle. Pourquoi resterait-elle encore à Beverly Hills? Lorsque sa mère meurt quelque temps après, elle part à Marrakech por vendre la maison dont elle vient d''hériter. Sans se douter à quel point la magie de cette ville - et sa rencontre avec Hafid- vont changer sa vie.Un livre de photos èmotionnnel.\"Comparada con lo que se ofrecía aquí, la ancha ronda era un sistema ordenado.",
    "year": 2013,
    "authors": [
      "Bernd Rücker"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2126
  },
  {
    "title": "MARRUECOS: VIAJE AL IMPERIO DE MULEY HASSAN",
    "isbn": "9788461659852",
    "synopsis": "La Editorial Roca-Franqueira Vicente edita el relato del viaje que realizó el escritor italiano Edmundo DAmicis a Marruecos a finales del siglo XIX.En 1875, el recién unificado Estado italiano envía su primera embajada a Marruecos con la finalidad de presentar sus credenciales al joven emperador Muley Hassan.Acompañaban al embajador Stefano Scovasso el escritor Edmundo de Amicis, muy popular en Italia por sus libros de viajes, y los pintores Stefano Ussi y Cesare Biseo, reputados orientalistas.El apasionante viaje, desde Tánger a Fez, se llevó a cabo al modo tradicional marroquí, acompañados por soldados del Sultán y protegidos por los jerifes de las tribus con las que se cruzaron, muchas de ellas insumisas hacia el Emperador y siempre hostiles hacia el extranjero, sobre todo si este era nazareno.Marruecos es la excelente crónica de aquella aventura narrada en un estilo romántico y realista que marcó tendencia en la literatura de viaje",
    "year": 2014,
    "authors": [
      "Edmundo de Amicis"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2132
  },
  {
    "title": "EXPLORACION DE LA PATAGONIA SUR II: EL LAGO ARGENTINO Y LOS ANDES MERIDIONALES (1877)",
    "isbn": "9789507542237",
    "synopsis": "Entre 1876 y 1877, a los 24 años de edad, Francisco Pascasio Moreno inicio su cuarto periplo patagónico. Este intenso y apasionante viaje quedo registrado, con bella y expresiva pluma, en su libro Viaje a la Patagonia austral, cuya primera parte se publicó en esta misma colección bajo el título Exploración de la Patagonia sur I. Por las cuencas del Chubut y el Santa Cruz (1876-1877). La presente edición incluye la segunda parte de ese extenso trabajo, que narra lo vivido por el explorador al llegar al lago Argentino y bautizarlo. Se le debe esta expedición no solo el haber navegado las aguas del hermoso lago por primera vez sino también el haber plasmado su reconocimiento geográfico en una obra literaria y científica que incluyo relevamientos cartográficos hasta entonces inexistentes. Antes de este viaje, la Argentina no disponía casi de documentación sobre el territorio patagónico.",
    "year": 2007,
    "authors": [
      "Francisco P. Moreno"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2247
  },
  {
    "title": "EL LEOPARDO DE LAS NIEVES (3ª)",
    "isbn": "9788478442621",
    "synopsis": "En otoño de 1973 el escritor Peter Matthiessen y el zoÛlogo George Schaller emprendieron una expediciÛn a la Montaña de Cristal, en la meseta del Tíbet, para estudiar los hábitos de un animal no muy conocido: el bharal o cordero azul himalayo. Pero su auténtica esperanza era poder ver al más hermoso y raro de los grandes felinos: el leopardo de las nieves.",
    "year": 1998,
    "authors": [
      "Peter Matthiessen"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2321
  },
  {
    "title": "EL VERTIGO HORIZONTAL",
    "isbn": "9788433961839",
    "synopsis": "Convencido de que quizá la Ciudad de México no sea la región más aconsejable para vivir, pero también de que es tan intrincada y apasionante que resulta imposible abandonarla, Juan Villoro propone este libro, escrito desde la devoción del urbanita recalcitrante y maravillado, que se despliega como un rompecabezas infinito: los atajos viales, el cine de luchadores, los héroes nacionales, el comercio tepiteño, la burocracia gubernamental, el enigma de las vulcanizadoras, las incontables multitudes, la ingesta de chile, los templos ancestrales.",
    "year": 2019,
    "authors": [
      "Juan Villoro"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2458
  },
  {
    "title": "TRES ANS VOYAGE: 25 PAYS PAR VOIE TERRESTRE, EN HISTOIRES ET EN I MAGES",
    "isbn": "9782866654283",
    "synopsis": "Avec une boîte d''aquarelle, un vieil appareil photo et un carnet de notes, Claire et Reno Marca partent en avril 2000 pour un long et beau périple qui les conduira, pendant trois ans, sur quatre continents et dans 25 pays. Jour après jour, de l''Afrique au Pacifique, ils vont tout consigner -par la couleur et les mots -pour ne rien oublier. Ils restituent ici, avec précision et sincérité, les aléas de leur quotidien de nomades, leurs rencontres, leurs enthousiasmes et leurs déceptions, et offrent un éclairage documenté sur les singularités culturelles de la situation politique des contrées traversées. Riche de plus de 700 illustrations, de nombreuses cartes géographiques et de petits livrets insérés, ce récit de voyage hors norme est un somptueux et passionnant atlas vécu.",
    "year": 2005,
    "authors": [
      "Claire Marca"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2487
  },
  {
    "title": "LA VUELTA AL MUNDO EN 10 AÑOS: EL LIBRO DE LA INDEPENDENCIA: TURQ UIA-SIRIA-JORDANIA-EGIPTO",
    "isbn": "9788461386789",
    "synopsis": "La vuelta al mundo en 10 años: el libro de la independencia es la historia de un sueño, de cómo un día dos personas normales deciden declarar su independencia y renunciar a la doble vida que nos arrastra a hacer los fines de semana todo lo que nos hubiera gustado vivir de lunes a viernes.",
    "year": 2010,
    "authors": [
      "Pablo Rey"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2499
  },
  {
    "title": "DIARIO GENERAL DEL VIAJE",
    "isbn": "9788477821168",
    "synopsis": "Esta colección publica y estudia los documentos más importantes y valiosos de la expedición Malaspina (1789-1798), la expedición marítima y científica más importante de la Ilustración española. Este segundo volumen, que por su extensión está dividido en dos tomos, presenta la trascripción del diario original de la expedición, que muestra claramente la importancia del viaje descrito por Alessandro Malaspina y su capacidad para dirigir la tripulación, como asimismo las investigaciones que realizaban los científicos y oficiales que integraban la expedición. Junto al diario y las cartas náuticas, los grabados y dibujos elaborados por los artistas de la expedición ayudan al lector a complementar la información del texto.",
    "year": 2007,
    "authors": [
      "Ricardo Cerezo Martinez"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2596
  },
  {
    "title": "MEMORIAS DE UN VIAJERO ABIERTO A LA VIDA",
    "isbn": "9788498860498",
    "synopsis": "Entre la Generación del 27 y la del 98. Siempre me han atraído las dos Generaciones. Verdad que he leído sólo algunos trozos de sus autores, pero he estado atento a lo publicado por ellos y sobre ellos. Es imposible leerlo todo. Estas memorias quieren ser un homenaje a ambas Generaciones. También el homenaje va dirigido a mis alumnos que tanto me han enseñado a lo largo de mis 50 años de profesor y a cuantas personas he tratado durante mi vida. No se trata de un relato cronológico, es más por lugares y temas. Quizá algún dato esté repetido, pero se debe en parte a que ese motivo lo he realizado en dos ocasiones distintas y para encuadrarlo. También advierto que fui religioso, por circunstancias especiales dejé la Orden de los Escolapios; más tarde conocí a María Teresa con la que me desposé y ella aparece en muchas ocasiones en este escrito.",
    "year": 2010,
    "authors": [
      "Felipe Sen"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2628
  },
  {
    "title": "HOMBRE SALVAJE",
    "isbn": "9788483078310",
    "synopsis": "Relato autobiográfico y libro de viajes, memoria y experiencias, Hombre salvaje, recoge las impresiones del periplo viajero de Tobias Schneenbaum por rincones inhóspitos de Perú, así como por Indonesia, Java, Sumatra y Borneo, regiones y paisajes donde el autor vivió muchos años. Con un estilo ágil lleno de inteligentes reflexiones sobre la condición humana y una prosa elegante, el autor nos guía por parajes imposibles al tiempo que nos da su visión del acelerado mundo contemporáneo y de las civilizaciones olvidadas o perdidas.Retratos, sensaciones y un agudo punto de vista sobre la realidad, esta obra es un clásico dentro de los libros de viajes, una lectura imprescindible para todos aquellos que deseen recorrer el mundo en el vagón de la literatura.á",
    "year": 2009,
    "authors": [
      "Tobias Schneebaum"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2644
  },
  {
    "title": "SOLO A TRAVES DEL ATLANTICO",
    "isbn": "9788474862607",
    "synopsis": "Este libro narra la travesía que realizó el autor, en 1923, a través del Atlántico desde Gibraltar a Nueva York.Alain Gerbault necesitó 101 días para atravesar el Atlántico y convertirse en el primero en conseguirlo de este a oeste en solitario y sin escalas.Posteriormente seguiría navegando hasta completar la vuelta al Mundo.Fue uno de los pioneros en realizar lo que ahora llamamos Partir. Dejó atrás una vida acomodada en la Europa de la postguerra, para marcharse a recorrer mundo en un barco de vela.Llama la atención los escasos medidos con que se navegaba en esa época. Una corredera remolcada por la popa, un sextante y un reloj constituían todos sus instrumentos de navegación.",
    "year": 2014,
    "authors": [
      "Alain Gerbault"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2649
  },
  {
    "title": "VIAJE A OAXACA",
    "isbn": "9788498678130",
    "synopsis": "Diario de Oaxaca es un libro de viajes muy poco convencional. Su autor, el prestigioso neurólogo y escritor Oliver Sacks, relata en estas páginas la expedición de diez días que emprendió, a principios de 2000, a la región de Oaxaca, en Mexico, con los miembros de la Sociedad Americana del Helecho, una treintena de personas de muy diversos origen y condición, unidos por el amor a las pteridofitas. Es esta la evocación de un viaje a un paraje uberrimo -setecientas variedades de helechos crecen en esta provincia mexicana-, y aunque el libro está lleno de curiosidades científicas, Sacks, observador avezado, no se limita a la naturaleza. Gastronomía, oficios, rituales y vestigios de antiguas civilizaciones desfilan por la narración bajo el singular prisma del neurólogo.",
    "year": 2010,
    "authors": [
      "Oliver Sacks"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2669
  },
  {
    "title": "TODAS LAS HISTORIAS Y UN EPILOGO: HISTORIAS DE LONDRES, HISTORIAS DE NUEVA YORK, HISTORIAS DE ROMA",
    "isbn": "9788490061190",
    "synopsis": "Este libro no sirve para adelgazar. Tampoco existe garantía de que mejore las perspectivas laborales o las relaciones familiares. Quien haya leído alguna de las tres obras aquí recopiladas (Historias de Londres, 1999; Historias de Nueva York, 2006; Historias de Roma, 2010) sabe ya que se expone a unas crónicas difícilmente clasificables, no del todo humorísticas ni del todo melancólicas, que componen la biografía íntima de unas ciudades maravillosas. También, de alguna forma, es la biografía de un tipo que tuvo la suerte de vivir en ellas y de conocer a gente extraordinaria.",
    "year": 2011,
    "authors": [
      "Beatriz Torvisco Manchon"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2685
  },
  {
    "title": "VIAJE DE UN NATURALISTA ALREDEDOR DEL MUNDO (T. 2)",
    "isbn": "9788473396936",
    "synopsis": "Edición en dos volúmenes del viaje alrededor del mundo que Charles Darwin realizó en 1831. De sus experiencias extraería los conocimietnos y las pruebas que luego le permitirían fundamentar su teoría evolucionista. Esta obra resulta de interés al conmemorarse en 2009 el año Darwin.En 1831, contando sólo con veintidós años de edad, Charles Darwin iniciaba su experiencia científica con una aventura singular: un viaje alrededor del mundo. Embarcado en el Beagle en calidad de naturalista, el investigador iría elaborando con todo detalle su diario a lo largo de los cinco años que duró la navegación. De esta actividad extraería los conocimietnos y las pruebas que luego le permitirían fundamentar su teoría evolucionista. El análisis comparativo de los pinzones americanos o el hallazgo de los fósiles marinos en las cumbres anidnas son hitos fundamentales, tal como aquí se describen, en la elaboración de sus descubrimientos.",
    "year": 1984,
    "authors": [
      "Charles Darwin"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2865
  },
  {
    "title": "CINCO HISTORIAS DEL MAR",
    "isbn": "9788423316083",
    "synopsis": "Un libro con sabor a sal, a pan; un reencuentro con la gente del pueblo y con la luz del mar. Uno de los textos más íntimos de Joseph Pla Este libro recoge algunas de las mejores páginas del autor relacionadas con el mar. Protagonista de cinco relatos, el Mediterráneo se disfruta desde diferentes perspectivas, en una muy planiana atención a los sentidos. ´Bodegón con peces´ es una singular presentación de la gastronomía y la pesca catalana a partir de los recuerdos de un pueblo tranquilo y luminoso -el Fornells catalán- que ni siquiera tenía cementerio, lo que ´daba la sensación -escribe Pla- a los que vivíamos allí de que no íbamos a morir nunca´; ´Un viaje frustrado´ nos aproxima al temperamento de la gente del Ampurdán, rebelde, soñador y discreto; ´Derrelictos´ y ´El naufragio del Cala Galiota´ son sendas historias de barcos hundidos, contados con la aparente objetividad del reportaje periodístico.",
    "year": 1988,
    "authors": [
      "Josep Pla"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3038
  },
  {
    "title": "BARROW Y SUS HOMBRES",
    "isbn": "9788482983417",
    "synopsis": "El atlas de 1816 estaba lleno de espacios en blanco. ¿Qué era el Polo Norte? ¿Existía un paso del Noroeste? ¿Qué había en el interior de África? ¿Existía la Antártida? Su empeño en encontrar las respuestas a esas preguntas, llevó al segundo secretario del almirantazgo británico, John Barrow, a poner en marcha el programa de exploración más ambicioso que se haya visto en el mundo.",
    "year": 2005,
    "authors": [
      "Fergus Fleming"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3254
  },
  {
    "title": "EL ULTIMO EXPLORADOR: LA VIDA DEL LEGENDARIO WILFRED THESIGER",
    "isbn": "9788432216800",
    "synopsis": "Enamorado del desierto y de sus gentes, el último representante de la tradición británica aunaba la literatura con la exploración, la biología con la lingüística, la historia con la etnografía; un heredero directo de Richard Burton y de Lawrence de Arabia. Una biografía inusual del \"Último explorador\" que sigue sus pasos descubriendo los aspectos más desconocidos.",
    "year": 2005,
    "authors": [
      "Manuel Leguineche"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3255
  },
  {
    "title": "CARTAS DE RELACION (20ª ED.)",
    "isbn": "9789700745336",
    "synopsis": "Las cinco cartas que aquí se ofrecen al lector, tradicionalmente llamada Cartas de Relación de Hernán Cortés, se hallan manuscritas, junto con otros documentos, en un códice de la Biblioteca Imperial de Viena. Su redacción va de los treinta y cuatro a los cuarenta y un años de su autor y están escritas en un castellano terso. La primera data de 1519 y la última de 1526. Es el propio Cortés quien en el contexto de tres de las comuicaciones las llama relación, pues en ellas da cuenta a Carlos V de las anécdotas y los hallazgos en la Nueva España, del asedio a Tenochtitlán y su posterior caída, de la organización y crecimiento de la nueva colonia, así como de su expedición a Honduras, entre otros asuntos. En todas las cartas manifiesta su pasmo y admiración ante las maravillas de las nuevas tierras y expresa su deseo de descubrir sus secretos.",
    "year": 2004,
    "authors": [
      "Manuel Alcala"
    ],
    "categories": [
      "Narrativa de viajes"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3257
  },
  {
    "title": "ENHORABUENA POR TU FRACASO",
    "isbn": "9788418051197",
    "synopsis": "El libro de Arturo González-Campos que te autoayuda a fracasar estrepitosamente en la vida«Amo las cosas y, por lo tanto, amo a las personas que hacen cosas. Gente que dedica su vida a hacer libros, pelis, canciones, cómics., cosas.Gracias a ellas soy un poco menos imbécil, lo cual, en mi caso, tampoco es mucho decir».Enhorabuena por tu fracaso es un desnudo integral de Arturo González-Campos, lo que no sabemos si dice mucho a su favor. Una oda a lo genuino y una invitación a que te atrevas a persistir en lo que te apasiona; a fracasar y fracasar y volver a intentarlo para, con toda probabilidad, seguir aprendiendo a fracasar. Este es un relato (¿o unas memorias?) sobre esos fracasos que, sólo a veces, se convierten en éxitos y que han permanecido en la mente de Arturo González-Campos durante toda su vida.",
    "year": 2022,
    "authors": [
      "Arturo Gonzalez Campos"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 10
  },
  {
    "title": "ACADEMIA DE MADRES: EL ORIGEN",
    "isbn": "9788427049697",
    "synopsis": "Madre está harta de que las técnicas ancestrales de la maternidad se estén perdiendo. Pero eso se va a acabar. Ella va a poner orden: ha fundado la Academia de Madres, donde compartirá con otras madres ávidas de sabiduría todos sus conocimientos, desde el legendario lanzamiento de chancla hasta las frasecitas de madre. En su camino la apoyará toda la familia: el distraído Padre, el encauzado Hijo Mayor, el olvidado Hijo Mediano y el mimado Hijo Pequeño. ¡Acompaña a Madre mientras pone un poco de sentido en este mundo de caos!",
    "year": 2022,
    "authors": [
      "Nachter"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 27
  },
  {
    "title": "DRAMA QUEEN",
    "isbn": "9788427049895",
    "synopsis": "¡Mira que eres dramas! Cansada de que me digan siempre que querer es poder, que lo importante es que me ría de mí misma y que todo es más sencillo de lo que me imagino, me planto ante la vida y pienso: ¿solo yo tengo problemas? En un mundo de influencers de pacotilla y de princesas yo elegí ser una persona que se come el mundo antes de que el mundo me coma a mí, aunque a veces tenga náuseas. Pero ¡cuidado! porque, sí, hablo de cosas de chicas y de chicos, de situaciones muy reales, de momentos alegres y de llanto, pero os lo digo alto y claro: todos y todas llevamos una Drama Queen dentro, solo hay que dejarla salir? Cuando una dramas escribe un diario, el resultado solo puede ser un relato muy gamberro y con mucho humor. @la_drama_queen",
    "year": 2022,
    "authors": [
      "La Drama Queen"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 42
  },
  {
    "title": "HEMODERIVADAS",
    "isbn": "9788412435344",
    "synopsis": "Pandora Ferreira-Bisset, una artista contemporánea influenciada por el movimiento espiritual Energía Menstrual Universal, está organizando los preparativos para la inauguración en Zúrich de su retrospectiva: Hemoderivadas, título que homenajea una trayectoria en constante diálogo con lo «esencial» femenino y los significados asociados tradicionalmente a la sangre. Narrada en forma de tríptico, se presenta en tres registros distintos: el presente de la artista en las horas previas a la exposición; las hilarantes descripciones de las piezas y los textos de sala de su comisaria, Renata Longhinini; y la voz de Estelita, una adolescente reclutada para ejecutar Némesis, la controvertida performance final y eje central en el que se vertebra esta historia.",
    "year": 2022,
    "authors": [
      "Ana Llurba"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 71
  },
  {
    "title": "EL FRUTO PROHIBIDO",
    "isbn": "9788418897528",
    "synopsis": "Una novela gráfica que toda madre debería regalar a su hija, ¡y toda hija a su pareja! El cómic feminista sobre la historia cultural de la vulva (dejaos de vaginas) que está cambiando el mundo.#VivaLaVulvaCierta parte de la anatomía femenina ha suscitado a lo largo de la historia, y sigue suscitando, el interés digamos que «vivo» de ciertos representantes del género masculino. Pero...",
    "year": 2022,
    "authors": [
      "Liv Stromquist"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 82
  },
  {
    "title": "PADRE, EL ULTIMO MONO",
    "isbn": "9788408003953",
    "synopsis": "Instrucciones para leer un libro de instrucciones1. Coja el libro de la estantería de la tienda de libros.2. Empiece a leerlo por delante (al revés de como lo está cogiendo ahora mismo).3. Hojéelo para ver si le interesa.4. En caso aﬁrmativo, diríjase a la caja y pague lo que le digan.Una vez en casa, descubrirá todo lo que necesita saber un padrey que, hasta ahora, nadie se atrevió a contarle. Capítulos tan útilescomo:- Bienvenido a la secta- Enhorabuena.",
    "year": 2012,
    "authors": [
      "Berto Romero"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 98
  },
  {
    "title": "NOSTALGIA MILENIAL",
    "isbn": "9788418040016",
    "synopsis": "Nostalgia milenial: el Yo fui a EGB de los milenials.¿Echas de menos... los tamagotchis?... los Power Rangers?... el Messenger?... el Grand Prix?... la falta de responsabilidades?Si la respuesta a la mayoría de preguntas es sí, no hay duda, lo que tú tienes se llama nostalgia milenial. Pero tranqui, ¡no es nada malo!Con este libro podrás recordar los desayunos con Megatrix, las tardes en el ciber, las canciones del verano o la llegada del Tuenti. También los politonos, el fenómeno Harry Potter o el primer OT. Podrás recordar lo maravilloso que fue crecer en pleno cambio de milenio.¿Te apuntas a este viaje al pasado? Pues sumérgete entre sus páginas y, como diría Mufasa, ¡recuerda quién eres!.",
    "year": 2021,
    "authors": [
      "Nostalgia Milenial"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 110
  },
  {
    "title": "MANUAL DE UNA AUTENTICA MAMARRACHA",
    "isbn": "9788427049482",
    "synopsis": "¡Hola, coleguis! Si algo me ha enseñado la vida es que cuando crees que has tocado fondo, de repente descubres que no, que hay más capas por debajo. Me río yo de las películas de terror. Este mundo sí que da miedo. Es normal ser una persona que no está ok cuando el mundo es un auténtico despropósito. La existencia a veces se nos hace bola. Ahora, como soy una tipa muy maja, aquí te traigo mi manual y guía de supervivencia. No sé si te ayudará a resistir, pero yo creo que, como poco, unas risas nos echamos.",
    "year": 2022,
    "authors": [
      "German Sanchez @gersanc"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 111
  },
  {
    "title": "ILUSTREPEDIA: ENCICLOPEDIA DEL DESCONOCIMIENTO",
    "isbn": "9788418260391",
    "synopsis": "Una desternillante enciclopedia ilustrada que resume el universo de Ilustres IgnorantesDurante trece años, Ilustres Ignorantes ha generado un sinfín de información irrelevante que ahora ha sido recopilada en un libro. Todo lo que Javier Coronas, Javier Cansado y Pepe Colubi han expuesto en el programa, junto con sus insignes invitados, llega hasta este ejemplar elaborado por el inigualable Dani Rodríguez, el guionista de este programa sin guion. Porque ¿en qué otro manual aparece el Principio de Incompetencia de Peter, la lista de patriarcas antediluvianos, la fórmula matemática del amor, el panóptico de Bentham, los inventos del profesor Bacterio, los signos del zodiaco de los dictadores o las tarifas de una funeraria? Hágase ya con este volumen único para convertirse en todo un ilustre ignorante.",
    "year": 2021,
    "authors": [
      "Ilustres Ignorantes"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 142
  },
  {
    "title": "(PE) EL RAPTO DE LA NOVICIA, LOS CAÑONES DE LOS PUJOL Y MONSIEUR PIPET DE LAGARDE",
    "isbn": "9788499986258",
    "synopsis": "Últimas y recientes aventuras del Marqués de Sotoancho.El marqués de Sotoancho, Cristián Ildefonso Laus Deo María de la Regla Ximénez de Andrada y Belvís de los Gazules, un peculiar señorito de la Baja Andalucía al que Ussía sitúa en La Jaralera, una residenciaficticia ubicada entre las provincias de Cádiz y Sevilla, regresa con una nueva aventura. Dentro de una galería de personajes que incluye yihadistas, guardias civiles, monjas variadas y una madre superiora, aparece Paula, una joven novicia que en el convento lleva el nombre de sor Verónica, a la que desea raptar, muerto de amor por ella, junto con sus soldados yugoslavos, en una disparatada y divertidísima trama.Con estos elementos, Ussía no solo se ocupa de narrar una estupenda historia, sino que subyace en ella una ácida y certera crítica de muchas situaciones de la sociedad española.",
    "year": 2018,
    "authors": [
      "Alfonso Ussia"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 147
  },
  {
    "title": "EN TU PUTA VIDA",
    "isbn": "9788417103583",
    "synopsis": "En tu puta vida también se podía haber titulado ¿Y por qué no?, pero este título resultaría engañosamente amable respecto del contenido de sus páginas, aunque, y aquí está la audacia del libro, resultaría igualmente válido. Y es que la destreza de este trabajo reside en mezclar en el alma del lector, y de manera indisoluble, sentimientos antagónicos a la vez. Hacerle probar un batido de desencanto y desánimo, con ilusión y esperanza. Pero no se trata de un balancín que se queda estable y nivelado entre optimismo y pesimismo en el interior del lector, sino más bien de uno que sube y baja mil veces frenéticamente con cada página. Se trata de un extraño y a la vez cotidiano surrealismo realista, historias contadas en género digito-epistolar, que por un lado el lector sabe que no le van a pasar y, por otro, también es consciente de la ausencia de motivos para que no le sucedan. En tu puta vida o ¿Y por qué no?",
    "year": 2018,
    "authors": [
      "Carlos Yuste"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 150
  },
  {
    "title": "CORAZONADAS",
    "isbn": "9788411282239",
    "synopsis": "Chumi Castejón y Mafalda Villegas son aparentemente un matrimonio feliz, dos famosillos sin oficio, pero con mucho beneficio, que dedican su vida al mundo de las exclusivas y que son las estrellas de un talk show titulado Corazonadas: telebasura en su máxima expresión. Cuando su popularidad comienza a decaer, son muchos los intereses que se tambalean, así que las mentes pensantes se tienen .",
    "year": 2022,
    "authors": [
      "Miguel Peidro"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 185
  },
  {
    "title": "NOVISIMAS AVENTURAS DE SHERLOCK HOLMES",
    "isbn": "9788492403097",
    "synopsis": "Antes de publicar Los 38 asesinatos y medio del Castillo de Hull [BREVIARIOS DE REY LEAR, nº 3], Enrique Jardiel Poncela escribió siete relatos y un prólogo protagonizados por Sherlock Holmes. Gracias a la buena acogida del público, con el último de ellos, junto a recortes del primero y del prólogo, compuso Los 38 asesinatos… Por tanto, estas Novísimas aventuras del detective inglés hacen gala de idéntico ingenio, con personajes que tienen voz «de patinador noruego», tardes que caen «sin hacerse daño» y, en general, un alarde de humor absurdo que mantiene constantemente la sonrisa en los labios del lector. La «resplandeciente prosa de Jardiel», como la califica en el prólogo el escritor Rafael Reig, es ilustrada en esta edición con dibujos del propio Jardiel.",
    "year": 2010,
    "authors": [
      "Enrique Jardiel Poncela"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 197
  },
  {
    "title": "LOS 38 ASESINATOS Y MEDIO DEL CASTILLO DE HULL",
    "isbn": "9788493524555",
    "synopsis": "De los numerosos textos apócrifos protagonizados por Sherlock Holmes, ninguno se equipara en imaginación y humor delirante a los escritos por Enrique Jardiel Poncela. Entre ellos sobresale Los 38 asesinatos y medio del Castillo de Hull, donde el detective inglés, que todos creen muerto en las cataratas del Niágara, encuentra un ayudante para sustituir al Doctor Watson. Ayudado por su nuevo compañero, Holmes emprende la resolución de una serie de misteriosos asesinatos perpetrados en un castillo de Escocia, que ponen a prueba sus capacidades deductivas. El final de esta parodia policiaca es aún más sorprendente que el de los relatos firmados por el verdadero padre literario de Holmes, Arthur Conan Doyle.",
    "year": 2010,
    "authors": [
      "Enrique Jardiel Poncela"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 203
  },
  {
    "title": "CONSEJOS PARA LAS NIÑAS BUENAS",
    "isbn": "9788496509412",
    "synopsis": "¿Cómo deben comportarse las niñas verdaderamente buenas? Mark Twain, uno de los maestros del humor de todos los tiempos, lo explica en este imprescindible manual de urbanidad que hará sonreír a todas sus bondadosas lectoras.",
    "year": 2006,
    "authors": [
      "Mark Twain"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 221
  },
  {
    "title": "(PE) HISTORIA DE UNA MUJER PLANTADA",
    "isbn": "9788427045323",
    "synopsis": "Una historia de amores y desamores con el peculiar sentido del humor de La Shatunga.Carmen acaba de cumplir 29 y en su propia fiesta de cumpleaños un chico la deja plantada…por enésima vez en su vida. Al día siguiente, cuando se despierta en la cama junto a su mejor amigo tras una borrachera, toma la decisión de cambiar su vida y, para conseguirlo, su propia terapia va a ser recordar todas las historias que ha vivido con los hombres: desde el estudiante de medicina que desaparece después de haberse sacado el MIR o el cuarentón que busca a una mamá para sus hijos, hasta el príncipe azul, romántico y siempre pendiente de ella, que acaba siendo un auténtico pelmazo.",
    "year": 2019,
    "authors": [
      "La Shatunga"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 228
  },
  {
    "title": "DICCIONARIO DE LA POLITICA ESPAÑOLA",
    "isbn": "9788417001629",
    "synopsis": "A través de una serie de entradas --\"Aprovechategui\", \"Beca\", \"Censura\", \"Carles Puigdemont\", \"Corrupción\", \"Máster\", \"Pablo Iglesias\", \"M. Rajoy\", \"Pedro Sánchez\"-- y alguna que otra frase célebre --\"Lo desconozco\", \"Usted se financia de Venezuela\", \"# y los españoles, muy españoles y mucho españoles\"--, Protestona y Anacleto Panceto --ácidos y geniales analistas de Twitter-- describen de forma voraz, cómica, informativa e irónica las dinámicas de la política española. Y lo hacen con un lema que lamentablemente en estos tiempos resulta indiscutible: la política en España parece una broma, y este libro también.",
    "year": 2019,
    "authors": [
      "Protestona"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 229
  },
  {
    "title": "ABCEDARI PER A ADULTS",
    "isbn": "9788494386039",
    "synopsis": "El primer abecedari per a adults fet per l''Òscar Dalmau i la Pilarín Bayés.Imagineu un llibre per aprendre totes les lletres de l''alfabet. Un llibre que no permetreu que mirin els vostres fills fins que siguin majors d''edat. Un abecedari on podreu aprendre, de manera amena i senzilla, paraules com ADULTERI, COCAÏNA, PUTA o SODOMIA. Aquest llibre pedagògic que us ajudarà a entendre el món meravellós que ens envolta, ha reunit un autor miop amb les ulleres més grosses del país, l''Òscar Dalmau, i una il·lustradora, mestra de mestres, la Pilarín Bayés, que, per primer cop, dibuixa per a uns lectors i lectores una mica més grans de l''habitual.Un abecedari realmentPROHIBIT PER A MENORS DE 18 ANYS.",
    "year": 2016,
    "authors": [
      "Oscar Dalmau"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 261
  },
  {
    "title": "LA BIBLIA SEGUN DIOS TUITERO",
    "isbn": "9788494991349",
    "synopsis": "En efecto, la Biblia es el libro más leído de todos los tiempos,pero ninguna de las numerosas versiones que conocéis es labuena. ¿Por qué? Porque todas fueron escritas por hombres. Ycomo toda obra humana, está repleta de fallos, imperfecciones.La Biblia contiene numerosos errores históricos, científicos,geográficos, lingüísticos... y contradicciones.Ahora medispongo a ofreceros la versión definitiva, la buena, la mía, ladivina, la del protagonista: La Biblia contada por Dios, por@diostuitero. Tomad y leed.Si, seas creyente o no, desdepequeño te dijeron que todo era pecado. Quizás no todo lo quete contaron fuera cierto.¡Nunca pensaste que te reirías tanto conla biblia!",
    "year": 2019,
    "authors": [
      "Dios Tuitero"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 311
  },
  {
    "title": "NOVEDADES, SOUVENIRS, ARTICULOS DE COÑA",
    "isbn": "9788493667658",
    "synopsis": "Si te subes a la lectura de este libro puedes coger el avión por los pelos, tener millones de dudas y no encontrar respuestas, porque si los Petit Suisse alimentan como un bistec, cuando van a caducar, ¿ los puedes empanar para que aguanten dos días más? Leyendo estos pensamientos podrás saber de qué hablan los esquimales, te preguntarás por qué Chuck Norris nunca ha conseguido el Oscar al mejor actor de reparto si nadie reparte como él y ¿ por qué no todas las pastas de dientes traen incluido el blanqueador ? ¿ Acaso hay a quién le gusta tener los dientes amarillos ? Podrás imaginar que las piedras están vivas, saber cómo es la república independiente de tu casa, enterarte por fin de quién era el poli que aseaba los caballos, convencerte de que el tamaño si importa y dudarás de si un fontanero es la persona más indicada para rescatar a la princesa en Super Mario Bros.",
    "year": 2014,
    "authors": [
      "Roberto Bodegas"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 361
  },
  {
    "title": "SÈRUM D UNA NIT D ESTIU",
    "isbn": "9788416930135",
    "synopsis": "La Satu, la Enfermera Saturada, la Florence Nightingale de les xarxes socials, torna a la càrrega amb un llibre més il·lustrat i acolorit que mai.Haurà aconseguit la plaça fixa? Haurà trobat l''amor? O, millor encara., tindrà ja el seu propi armariet?Cansada dels torns de nit que no s''acaben mai? La teva supervisora no col·labora en el pot de cafè i, a sobre, esmorza dues vegades? No suportes aquella companya que s''amaga al lavabo quan sona el timbre del pacient aïllat?",
    "year": 2017,
    "authors": [
      "Enfermera Saturada"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 371
  },
  {
    "title": "LA CRISIS EN OREJILLA DEL SORDETE",
    "isbn": "9788467025446",
    "synopsis": "—¡Doña Rogelia, doña Rogelia, que salimos otra vez en los papeles!—¿Mandeee? No será en los del Bárcenas…—Que no, doña Rogelia. ¡Que tenemos otro libro!—¡Mecagüenlaleche! Levánteme uste un poco el pañuelo de losáojos, cojona, que me se ha caído del susto. ¿Y eso?—Pues que vinieron los de la editorial a preguntarme si podía ustedádarnos alguna idea para salir de la crisis. Y yo les he dicho que sí, claro:áno están los tiempos para andarse con tonterías. Así que ya puede ustedáempezar a inventarse algo, algún consejo…—¡Recoña! Por poder claro que puedo. ¡Hala! Hagan tos ustedesásus maletas y vámonos pa Orejilla, que allí guardo unas noticas queáfui tomando, de cuando la posguerra, con trucos y triquimañas pa irátirando y aguantar el tirón. Ahora, que lo mismo no las encuentro,á¿eh?—Pues tendremos que pedirles a los otros que nos echen una mano.á¡Nikol, Rody, Daisy! Venga, todos conmigo. ¡Que nos vamos a Orejilla!á",
    "year": 2013,
    "authors": [
      "Doña Rogelia"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1300
  },
  {
    "title": "CINCUENTA SOMBRAS DE GREGORIO",
    "isbn": "9788408050957",
    "synopsis": "Grey es apuesto, rico, misterioso y tiene un lado oscuro excitante. Toca el piano, regala coches y nos ofrece experiencias inolvidables. Entre las sábanas es el rey, es capaz de despertar nuestros deseos más íntimos. Gregorio se pasea por casa enfundado en una camiseta vieja. Es un negado para detectar nuestras preocupaciones o satisfacer nuestros deseos más íntimos. Gregorio es el hombre corriente, plagado de defectos, con quien nos encontramos cara a cara cuando dejamos de soñar despiertas con Grey. De todos modos, admitámoslo: quizás sea menos encantador, pero es mucho más divertido, por lo menos por 50 razones, todas ellas presentes en este libro.",
    "year": 2013,
    "authors": [
      "Rosella Calabro"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1311
  },
  {
    "title": "LA PASION SEGUN DON MATEO",
    "isbn": "9788415584353",
    "synopsis": "Los milagros del Padre Pío de Pietrelcina contados con el humor que le cabe a un ateo. La historia discurre en Grenoble, el año de las olimpiadas de invierno. Una familia grenoblesa se ve agraciada con las visitas bilocacionales del fraile, para desgracia de todos. Un estudiante que se hospeda en la casa logra desentrañar los misterios con la ayuda del párroco de la iglesia vecina. Se trata de la ópera prima del autor, quien, después de muchos años como traductor, pensó que la hora había llegado de escribir lo suyo. Y lo suyo le ha costado. Horas de investigación con que unir fantasía y realidad, sin menospreciar, en modo alguno, el humor. Un humor que le lleva a afirmar que dios existe únicamente porque no somos inmortales",
    "year": 2013,
    "authors": [
      "Carlos Garcia Rodriguez"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1365
  },
  {
    "title": "LO MEJOR DE GILA (INCLUYE DVD)",
    "isbn": "9788467038743",
    "synopsis": "En 2011 se han cumplido 10 años de que nos dejara Miguel Gila, uno de los más grandes humoristas de todos los tiempos. ¿Quién no recuerda su imagen en blanco y negro, siempre con un teléfono en la mano…? El cable retorcido de aquel teléfono negro es el hilo que cose las páginas de este libro, en el que cobran nueva vida sus mejores monólogos: La factura del colegio, Las broncas de la señora. El ataque del enemigo,. La subida del paro. Un médico que no cura. Un mendigo que no come. Problemas, Absurdos. ¿Quién no querría levantar un teléfono y que todo se solucionase en una llamada? Parece imposible, pero no lo es. No del todo. El teléfono de Gila no era una varita mágica para resolver entuertos, pero si, desde luego, para responder con sorna a las muecas de la vida.",
    "year": 2011,
    "authors": [
      "Miguel Gila"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1430
  },
  {
    "title": "COMO NO SER EL PERFECTO MARIDO",
    "isbn": "9788497940689",
    "synopsis": "Ulysses Brave Many people find it difficult to discover their role in modern society. Instead of offering advice or solutions, these guides poke fun at issues that are often taken too seriously. Featuring humorous and unique photographs of bears, birds, dogs, and other creatures, the author draws inspiration from the animal world to reflect on important life topics. Para muchas personas es difícil desenvolverse en la sociedad moderna. En vez de ofrecer soluciones y sugerencias, estas guías dan lugar al humor y a la diversión. Incluyendo fotografías originales y curiosas de pájaros, osos, perros y otras criaturas, este libro saca inspiración del mundo animal para reflejar en los temas significantes.",
    "year": 2008,
    "authors": [
      "Ulyses Brave"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1466
  },
  {
    "title": "CHISTES SOBRE ZAPATERO",
    "isbn": "9788492520114",
    "synopsis": "Chistes sobre ZP le ofrece un amplio abanico de chistes en los que el presidente del gobierno, José Luis Rodríguez Zapatero, es el protagonista. Un valioso tratamiento antiestrés para superar ―como recomienda el presidente― la crisis con optimismo. Situaciones cómicas, respuestas alucinógenas, enriquecedoras conversaciones con compañeros del PSOE y con los socios nacionalistas… disfrute con las hilarantes anécdotas y chistes de este libro con las que no podrá reprimir la carcajada. Incluye un capítulo de frases reales pronunciadas por Zapatero que, de no haber salido de la boca del presidente, hubiesen podido engrosar perfectamente la relación de chistes que se incluyen en este libro.",
    "year": 2009,
    "authors": [
      "Juancal Rilla"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1546
  },
  {
    "title": "LOS HOMBRES QUE NO ATABAN A LAS MUJERES",
    "isbn": "9788493643096",
    "synopsis": "Un escritor de novela negra descubre, después de su muerte, que sus herederos han manipulado la obra que escribió y se han hecho de oro gracias a su legado. Así que decide dar a conocer la novela que él escribió en realidad, que no es otra que la que el futuro lector podrá sostener en sus manos. Se trata de una parodia delirante de uno de los mayores éxitos del mundo editorial, crítica despiadada, brutal y divertidísima de ese género extraño, y moralmente ambiguo, que conocemos como best-seller.",
    "year": 2010,
    "authors": [
      "Ste Arsson"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1595
  },
  {
    "title": "LOS SACRAMENTOS CIVILES",
    "isbn": "9788492868247",
    "synopsis": "\"El exacerbado afán actual de nuestros gobernantes por imponer el laicismo más puro, podría provocar situaciones como las que se muestran en los relatos de este libro: un Sr. Alcalde al que la Ley del Bautismo Civil le coge un poco por sorpresa y ha de poner en marcha toda su creatividad para salir del paso, o una señorita que aunque de vuelta de casi todo, ve en la Confirmación Civil un camino expedito para el logro de sus intereses.Con un humor surrealista y casi esperpéntico el autor realiza un recorrido por los siete Sacramentos, que le sirve de excusa para poner en solfa aquellas situaciones en las que pretenden hacernos creer que por el hecho de ser ciudadanos o ciudadanas por encima de personas, vamos a ser más libres. \"",
    "year": 2010,
    "authors": [
      "Juan Luis Cantador Luceno"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1632
  },
  {
    "title": "COMO SABER SI TU NOVIO ES EL ANTICRISTO",
    "isbn": "9788448067960",
    "synopsis": "¡Se acabaron las citas con embusteros, mentirosos y perfectos inútiles!Este libro nos muestra las principales características de más de 70 tipos de hombre y además nos aconseja para que, después de la primera cita, podamos decidir si seguimos con él o le damos la patada.",
    "year": 2010,
    "authors": [
      "Patricia Carlin"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1688
  },
  {
    "title": "SEVILLA LLENA ERES DE GRACIA",
    "isbn": "9788493948801",
    "synopsis": "Este es un libro, indudablemente para REIR, pero también para PENSAR y reflexionar sobre el HUMOR en general y el de los sevillanos en particular. Para conseguir este objetivo, el autor, ha acudido a escritores, dibujantes y periodistas de Sevilla, que han utilizado el humor como forma de expresión y que, a estas alturas, se merecen un público y reconocido homenaje, que les rindo desde estas páginas. También se ha aproximado a quienes “fabrican” ese humor y a quienes se atreven a enjuiciarlo desde su personalísimo punto de vista.",
    "year": 2011,
    "authors": [
      "Joaquin Arbide"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1788
  },
  {
    "title": "LA LEY DE MURPHY DEL AMOR: VAYA LO QUE VAYA MAL, SU PAREJA YA SE LO IMAGINABA",
    "isbn": "9788484609803",
    "synopsis": "El rey del pesimismo ataca de nuevo y esta vez para... ¡hablar del amor!El rey del pesimismo ataca de nuevo y esta vez para... ¡hablar del amor! No escapan a su lengua mordaz, a su despiadada mirada, ni los jóvenes enamorados, ni los recién casados, ni los que se han metido en el lío de ser padres, ni las parejas que, a pesar de todo, llegan a cumplir sus bodas de oro.Desde el momento del flechazo o la cita a ciegas, hombres y mujeres viven como en una nube, encantados con su pareja, sin saber que las cosas irán necesariamente de mal en peor.•Es imposible amar y ser sabio a la vez.•En una relación, la imperfección oculta nunca permanece oculta.•El sexo es una de las nueve razones que existen para creer en la reencarnación.",
    "year": 2002,
    "authors": [
      "Arthur Bloch"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 1796
  },
  {
    "title": "LA LEY DE EL SEVILLA.",
    "isbn": "9788467009316",
    "synopsis": "Con un sentido del humor irreverente y un lenguaje sin concesión alguna al pudor, El Sevilla pasa revista a diversas situaciones cotidianas que definen el complejo mundo de la pareja. Teorías y reflexiones de un autentico experto en artes amatorias. Un libro de humor que trata de cosas muy serias. Las relaciones de pareja son el motor del mundo y, con frecuencia, el mejor ejemplo de que la celebre Ley de Murphy existe y suele cumplirse. ¿Que es lo que funciona en la cama?, ¿que es lo que, definitivamente, nunca debes poner en práctica?, ¿por que ellas interpretan una cosa cuando ellos están pensando en la contraria?, ¿cómo alcanzar el exito o, al menos, cómo no caer en el más estrepitoso de los fracasos?, ¿por que lo que hasta ahora era que sí, a partir de un momento es ya que no?",
    "year": 2012,
    "authors": [
      "Miguel Angel Rodriguez"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2074
  },
  {
    "title": "REFLEXIONES DE UN DESGRACIAO",
    "isbn": "9788461321933",
    "synopsis": "\"El autor recomienda encarecidamente –dado el alto nivel cultural e intelectual de la obra– que desista de la lectura de la misma, aconsejándole Que primero aprenda a escribir (empezando por el abecedario), al mismo tiempo que aprende a leer (le recomiendo empezar por los clásicos «tebeos» Españoles). El autor no se hace responsable de las posibles molestias (cefaleas, migrañas, dolores de cabeza y jaquecas varias, aparte de otros problemas más graves como pudieran ser embolias, trombosis, o hemorragias o derrames cerebrales, amén de diarrea mental crónica debido al esfuerzo que usted va a verse obligado a realizar para poder Enterder Semejante «joya» de la literatura universal. No se descarta la muerte del lector) que Pudiera sufrir, tanto durante como después de la lectura de la obra.\"",
    "year": 2009,
    "authors": [
      "Miguel Angel Febrero Carmona"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2486
  },
  {
    "title": "JUNTOS SIETE AÑOS",
    "isbn": "9788498382280",
    "synopsis": "Se enrollaron en Finalmente juntos, se casaron en Juntos otra vez, y ahora se enfrenta a la fatídica crisis de los siete años.Amy y Jack, los jóvenes londinenses que nos hicieron troncharnos de risa en Finalmente juntos, ya no tienen veinte años. En teoría, siguen siendo la pareja ideal, pero muchas cosas han cambiado; por ejemplo, son padres de un niño de dos años y no han tenido más remedio que hacer frente a la odiosa madurez. Y ahora, tras los consabidos siete años de matrimonio, se encuentran nadando esforzadamente en el proceloso mar de la paternidad, las tareas domésticas, la escasez de intimidad y el distanciamiento de los amigos. La vida en casa se ha vuelto aburrida y monótona, poblada de desencuentros, discusiones y malentendidos. Sin embargo, no todo está perdido. Ahí fuera sigue habiendo un mundo vivo y activo, un lugar lleno de posibilidades y tentaciones difíciles de resistir.",
    "year": 2009,
    "authors": [
      "Josie Lloyd"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2630
  },
  {
    "title": "ANECDOTAS DE LA GUARDIA CIVIL",
    "isbn": "9788448048815",
    "synopsis": "Dos guardias civiles atacados por un emú, una gitana que asegura que las mil bragas robads con las que la pillaron eran la dote de su nieta, una venerable ancianita con un completo surtido de vibradores atestando su maleta: con esta y otras muchas situaciones- divertidas , curiosas, simpáticas y hasta paranormales - han tenido que enfrentarse los agentes de este cuerpo a lo largo de más de ciento cincuenta años de servicios y patrullas por España.",
    "year": 2009,
    "authors": [
      "Francisco Botana"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2639
  },
  {
    "title": "ANECDOTAS DE TAXISTAS",
    "isbn": "9788448067793",
    "synopsis": "Cada vez que se baja la bandera se levanta el telónEl asiento trasero de un taxi es el escenario por el que desfilan todo tipo de personajes y donde suceden las historias más insospechadas. Cada vez que se baja la bandera se sube el telón y empieza el espectáculo: pasajeros que duermen como marmotas, famosos adivinos que se aparecen por toda la ciudad como visiones, machotes de cadena en pecho, ejecutivos agresivos y familiares aún más agresivos; urgencias que no son tales, partos inminentes y un sin fin de situaciones cada cual más surrealista que aseguran la carcajada.Anécdotas de Taxistas nos muestra algunas de las aventuras más divertidas de este gremio. Una prueba de que tras el retrovisor de sus coches estas personas son testigos de lo variopinto de la condición humana.",
    "year": 2010,
    "authors": [
      "Diego Perez Carpeño"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2682
  },
  {
    "title": "LOS MEJORES CHISTES 3",
    "isbn": "9789500204859",
    "synopsis": "Si mal no recuerdo, usted fue el que compró El gran libro de los chistes, luego Los mejores chistes 1, finalmente Los mejores chistes 2, y ahora, viendo este ejemplar, está pensando si compra Los mejores chistes 3. ¿Tiene alguna duda para llevarlo? Hace bien, la duda es el principio de la sabiduría, dijo Aristóteles. Pero ¿es posible que deje la colección sin completar? Además, si lo compra, no sólo tendrá todos los libros sino que éste que está en sus manos trae nuevas secciones y una cantidad enorme de chistes seleccionados para que usted se luzca en cualquier reunión. Desde luego, si me equivoqué y usted no es el que compró los libros anteriores, ¿qué está esperando para empezar con el que tiene en las manos? Hágame caso: tome el libro, pase por la caja (le aviso que hay una chica muy hermosa atendiendo y no está para perdérsela) y llévelo a su casa.",
    "year": 2009,
    "authors": [
      "Julio Cesar Parissi"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2683
  },
  {
    "title": "LO MEJOR DE LOS MORANCOS (INCLUYE DVD)",
    "isbn": "9788467038125",
    "synopsis": "Humor para todos los públicos, de la mano de dos grandes maestros del ingenio. Una extensa recopilación de los mejores momentos de Los Morancos. Sus gags más célebres, las situaciones más descabelladas, los episodios más desternillantes de estos dos maestros del humor, cuyos personajes se han convertido en auténticos iconos de nuestra cultura popular. ¿Quién no se acuerda de Omaíta, de Antonia, del Joshua…? ¿Quién no ha disfrutado con las imitaciones de famosos protagonizadas por Los Morancos; de sus versiones de canciones de éxito; de ese extenso repertorio de personajes variopintos que protagonizan situaciones delirantes pero tan cercanas.? Las páginas de este libro destilan un humor amable y popular que arranca carcajadas.",
    "year": 2011,
    "authors": [
      "Cesar Cadaval"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2697
  },
  {
    "title": "ANECDOTAS DE PELUQUEROS",
    "isbn": "9788448069919",
    "synopsis": "Un error en un movimiento de la tijera y ¡zas! ahí va un flequillo que queda más corto de la cuenta. Un despiste con una tintura destinada a rejuvenecer que acaba en un maravilloso pelo cano, gajes del oficio de un peluquero que están a la orden del día.Pero en un salón de belleza no todos son tijeras y tinturas. La clientela más fiel sabe que aquellas sillas, o incluso el lavacabezas, pueden ser mejor mucho mejores que el diván de un psicólogo.",
    "year": 2011,
    "authors": [
      "Antonio Garrido"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2771
  },
  {
    "title": "ELS 155 MANAMENTS",
    "isbn": "9788494625251",
    "synopsis": "Un dia fred de febrer del 2018 en trobava a una terrassa de Grácia amb una copa a la má quan es va obrir el cel i van aparéixer el Joan Capri,el Rubianes i el José Luis Cuerda. Aquest últim no sé per qué va parlar des del Cel,perqué encara viu i em podia haver trucat al mòbil.",
    "year": 2021,
    "authors": [
      "Moises Peñalver"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2789
  },
  {
    "title": "EPITAFIOS CASI REALES",
    "isbn": "9788415528074",
    "synopsis": "En esta obra en cuyo título se homenajea al recordado humorista José Luis Coll, este maestro del aforismo nos invita a echar una carcajada, a ver con perspectiva a personajes históricos y a apreciar desde la cercanía en el tiempo a otros, más contemporáneos, de los que consigue sacar el jugo de su personalidad, la esencia de lo que son o de lo que parecen ser para la sociedad.",
    "year": 2012,
    "authors": [
      "Francisco Jimenez"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2826
  },
  {
    "title": "EL HOMBRE QUE SOLO PODIA QUEDARSE UN RATITO",
    "isbn": "9788490112243",
    "synopsis": "¿Hay forma de librarse de Julia Roberts cuando se pone besucona? ¿Puede Harry Potter regentar con acierto una taberna en donde solo se despachan botellines? ¿Qué hacen dos ancianitas en un ascensor guitarra en mano a las tantas de la noche? ¿Es fácil ganarle a Cervantes en un concurso de escritura rápida? ¿Cuál es el mejor sistema para veranear en agosto sin gastarse un euro? ¿Resulta inapropiado escalabrar a un político con una réplica en escayola de la Monumental de las Ventas?",
    "year": 2012,
    "authors": [
      "Juan Jose Isac"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 2837
  },
  {
    "title": "(I.B.D.) UNCLE DONALD MAKES AMERICA GREAT AGAIN",
    "isbn": "9788417887148",
    "synopsis": "¿Un cómic en clave de humor de cuatro años de delirio en la era Trump?Yes, we did. Uncle Donald makes America great again es una crónica visual del ascenso al poder y gobierno del expresidente de Estados Unidos, referente de los populismos extremistas que están prendiendo por todo el globo. En estas páginas podrás ver sus soluciones fáciles para problemas complejos, su utilización de Twitter y de otras redes sociales para manipular a la opinión pública, sus tics racistas, xenófobos y machistas. ¿Te atreves a echar un vistazo?",
    "year": 2021,
    "authors": [
      "Miguel Nuño"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3137
  },
  {
    "title": "¿A CUANTOS SAPOS HAY QUE BESAR PARA ENCONTRAR UN PRINCIPE?",
    "isbn": "9788403096530",
    "synopsis": "Al abrir este libro, no esperes encontrar un tratado sobre los sapos ni la fórmula mágica para encontrar un príncipe (entre otras cosas, porque ya no estamos seguros de que existan los príncipes azules). Lo que sí vas a encontrar es el desnudo en cuerpo y alma de Deborah Ombres. Será la primera y la última vez que hable de su vida privada y sexual. Deborah ha sufrido una auténtica plaga de sapos. Y no creas que es la única. Los sapos están presentes en nuestro día a día: sales a la calle y hay millones de sapos, entras en un bar y los hay a cientos, en tu casa puedes tener ya un sapo que se ha apoderado de tu ecosistema y tú ni te has enterado. Esperemos que se convierta en príncipe cuando lo beses para averiguarlo. Este libro es una especie de guía para vosotras, pues sirve para poder identificar de manera rápida a este tipo de seres.",
    "year": 2005,
    "authors": [
      "Deborah Ombres"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3375
  },
  {
    "title": "LAS MEJORES CITAS HUMORISTICAS",
    "isbn": "9788479277659",
    "synopsis": "Esta entretenida obra pone a su alcance un amplio y práctico repertorio de las más cómicas frases célebres. Una amplia gama de recursos humorísticos que, además de divertirle, servirá para animar y enriquecer todo tipo de situación comunicativa oral: discursos, conferencias, reuniones.",
    "year": 2005,
    "authors": [
      "Samuel Red"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3401
  },
  {
    "title": "LOS MEJORES CHISTES",
    "isbn": "9789500274647",
    "synopsis": "No hay nada más grato que contar chistes. Además, ser el tipo ingenioso y divertido de la reunión, nos levanta la autoestima como lo dijo el psicólogo, y yo le creo, y usted no es de los que pasan desapercibidos sino de aquellos que siempre se destacan. Pues bien, ¿cómo hace para lograr eso? Muy sencillo: debe andar pertrechado con una batería de chistes que no se termine nunca y le quede una reserva para contar y contar hasta que las velas no ardan. Nunca va a faltar ocasión para largarse con un buen relato humorístico.Si leyó hasta aquí, sabe que tiene en sus manos el libro que le proporcionará placer mientras lo lee y, además, podrá tomar el material que será la nota divertida para mechar en las charlas con sus amigos. Ningún tema o lugar lo encontrará desprevenido, porque el chiste que usted quiere contar sobre cualquier asunto está en este volumen.",
    "year": 2004,
    "authors": [
      "Julio Cesar Parissi"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3419
  },
  {
    "title": "¡AUN MAS BESTIA!: LOS CHISTES DE INTERNET",
    "isbn": "9788479277086",
    "synopsis": "Si el humor mordaz del libro ¡Qué bestia! te escandalizó, te pareció políticamente incorrecto, hirió tu sensibilidad y te arrancó carcajadas salvajes, prepárate porque está segunda parte es aún más cañera y, por lo tanto, más desternillante. Ningún colectivo se salva de los chistes bestias recopilados por el Dr. Rocaviva, cada vez más machistas y racistas, sin ningún tipo de pudor sexual y que se recrean tanto con los feos como con los guapos, los idiotas, los deportistas, los homosexuales, los catalanes, los andaluces, los políticos... todo bicho viviente que se atreva a respirar puede ser motivo de burla y risa. Quizás te creas que contigo no hay quien se meta, pues te equivocas ¡seguro que también eres motivo de chiste!",
    "year": 2004,
    "authors": [
      "Rocaviva"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3452
  },
  {
    "title": "DICCIONARIO INCONVENIENTE",
    "isbn": "9788479489786",
    "synopsis": "Diccionario Inconveniente es una miscelánea de palabras inventadas o bien definidas con su verdadero espíritu; acompañadas por una galería de sucintas biografías de personajes que, si no han existido, bien podrían haberlo hecho. Un recorrido caleidoscópico por el intrigante mundo de la política, en clave de humor, que pretende divertir, emocionar y, en último caso, proponer una reflexión sobre los resortes del poder. Claro que, dicho así, es posible que el autor no venda ni un solo ejemplar.Un libro que nos sumerge en un universo paralelo de reyes imbéciles, presidentes estúpidos, financieros malvados, revolucionarios oligofrénicos y santos epilépticos. Un catálogo de conceptos y vidas ejemplares que, a pesar de ser fruto de la fantasía, bien podrían ser perfiles exactos de la cruda realidad.Y ahora, si aún no te has convencido de la necesidad de leerlo, deja otra vez este libro en su estantería.",
    "year": 2013,
    "authors": [
      "Xavier Theros"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3453
  },
  {
    "title": "LA BODA DEL SEÑOR CURA",
    "isbn": "9788467012811",
    "synopsis": "Corren los años cincuenta. El padre Juan Camí es profesor en un colegio de jesuitas. Pero a medida que avanza el siglo el sacerdota va evolucionando y se hace militante de comisiones obreras y acaba siendo marido de una bailarina de Streap-tease.",
    "year": 2003,
    "authors": [
      "Fernando Vizcaino Casas"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3479
  },
  {
    "title": "LA CHAPUZA NACIONAL: MAXIMAS, MINIMAS Y PROSAS INTERMEDIAS",
    "isbn": "9788484602866",
    "synopsis": "La gracia y agudeza de Fernando Vizcaíno Casas en un libro singular. Un libro divertido, ameno, variado y con la mala uva indispensable, la retranca necesaria y la socarronería característica de quien es el escritor más aplaudido de la España contemporánea.",
    "year": 2003,
    "authors": [
      "Fernando Vizcaino Casas"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3482
  },
  {
    "title": "FROM LOST TO THE RIVER & SPEAKING IN SILVER",
    "isbn": "9788484601517",
    "synopsis": "From lost to the River (De perdidos al río) & Speaking in Silver (Hablando en plata) Si entiendes a la primera frases como: Here my saint, Marychestnut`s year, To cost a Kidney, etc., tú eres la persona que estamos buscando. Ahora tienes la oportunidad de volver del revés todos aquellos sufrimientos, horas y dineros gastados en convertirte en angloparlante.",
    "year": 2004,
    "authors": [
      "Ignacio Ochoa"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3483
  },
  {
    "title": "NUMEROS PARES, IMPARES E IDIOTAS",
    "isbn": "9788497931595",
    "synopsis": "Dos talentos inusuales y originalísimos que se asocian en este libro para todas las edades. Una reivindicación del juego y la libertad, plasmada en estos cuentos sabiamente ilustrados, y que ironizan sobre el mundo de los números, sus competencias y sus egos. Los números que se niegan a ser divididos, sumados y multiplicados, y se quejan de tener siempre por encima números más altos y fuertes.",
    "year": 2004,
    "authors": [
      "Juan Jose Millas"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3492
  },
  {
    "title": "LOS PREMIOS DARWIN",
    "isbn": "9788466311533",
    "synopsis": "Llamados así en honor del padre de la evolución, los premios Darwin recompensana aquellos que mejoran nuestro patrimonio genético eliminándose a sí mismos,demostrando así lo poco común que puede llegar a ser el sentido común.Lea el caso del terrorista que abre una carta bomba que le ha sido devuelta. Maravíllesedel ladrón que roba cables sin cortar antes la corriente. Y aprenda del hombre que miraen el interior de un bote de gasolina iluminándose con un mechero. La supervivenciaen todo su esplendor selectivo.",
    "year": 2003,
    "authors": [
      "Wendy Northcutt"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3509
  },
  {
    "title": "LAS OCURRENCIAS DE PEPE PEREZ PEREGIL: TAL Y COMO SE LAS CONTO A JOAQUIN ARBIDE (5ª ED.)",
    "isbn": "9788495724267",
    "synopsis": "De aspecto y voz de gigante, Peregil siempre cuenta historias mínimas que, sin embargo, y haciendo honor a su apodo, desprenden un sabor inmenso. Es hijo, nieto y bisnieto de “Peregiles” y todo viene de un hombre bueno y gracioso llamado realmente José Pérez Gil, al que se le quedó aquello de “Peregil”. Además de regentar su taberna Quitapesares, junto al célebre Hotel Don Paco de Sevilla, siempre repleto de autobuses de turistas, cantera de personajes y ambientes únicos como Peíto y Risitas, es cantaor y saetero, poeta a su manera y rociero, además de enorme enamorado de Sevilla y sus dos semanas grandes, la Feria y la Semana Santa, fecha en las que no duda en asomarse a cualquier balcón para cantarle a todas las Hermandades de Sevilla. De todo ello puede contar mil y una historias dejando pellizcos de su enorme y singular gracia",
    "year": 2003,
    "authors": [
      "Jose Perez Blanco"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3521
  },
  {
    "title": "HISTORIAS DE CURAS",
    "isbn": "9788427028890",
    "synopsis": "El sentido del humor del padre Jesús Núñez es proverbial. Como él mismo asegura, la fe no está reñida con el buen humor, el ingenio y la ironía, y por eso nos presenta esta selección de chistes y anécdotas que ha ido reuniendo a lo largo de su vida.",
    "year": 2002,
    "authors": [
      "Jesus de Albendrele"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3613
  },
  {
    "title": "LOS MEJORES CHISTES DEL MUNDO 2",
    "isbn": "9788479276379",
    "synopsis": "En este nuevo libro, Samuel Red nos hace comprobar que, pese a los malos tragos de la vida y a los delicados tiempos que vivimos, cada vez somos más conscientes de lo necesaria y terapéutica que es la risa. El excelente e inteligente humor de esta nueva colección de chistes inéditos se convierte, así en un arma inmejorable para afrontar momentos difíciles de todo tipo.",
    "year": 2002,
    "authors": [
      "Samuel Red"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3692
  },
  {
    "title": "OS LO TENGO DICHO: MI VIDA COTIDIANA COMO HOMBRES",
    "isbn": "9788426448811",
    "synopsis": "Cuarenta y ocho historietas en cada libro que describen, en clave de humor, situaciones cotidianas, acompañadas por originales ilustraciones. Todas las anécdotas, narradas en primera persona, se caracterizan por su pequeñez: no encontrar nunca dos calcetines del mismo par o perder el filtro de la cafetera precisamente cuando hay que acabar un trabajo urgente a una hora intenpestiva, ir de compras y volver a casa con cosas inutiles, hacer deporte para rebajar vientre, no entender por qué tu mujer esta obsesionada con Alain Delon, los madrugones, los novios de las hijas. El protagonista de estos libros tiene cuarenta y dos años y se enfrenta a todas las crisis que surgen a esa edad.",
    "year": 2002,
    "authors": [
      "Axel Hacke"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3729
  },
  {
    "title": "PERO SI A MI NADIE ME HACE CASO",
    "isbn": "9788426448804",
    "synopsis": "Cuarenta y ocho historietas en cada libro que describen, en clave de humor, situaciones cotidianas, acompañadas por originales ilustraciones. Todas las anécdotas, narradas en primera persona, se caracterizan por su pequeñez: no encontrar nunca dos calcetines del mismo par o perder el filtro de la cafetera precisamente cuando hay que acabar un trabajo urgente a una hora intenpestiva, ir de compras y volver a casa con cosas inutiles, hacer deporte para rebajar vientre, no entender por qué tu mujer esta obsesionada con Alain Delon, los madrugones, los novios de las hijas. El protagonista de estos libros tiene cuarenta y dos años y se enfrenta a todas las crisis que surgen a esa edad.",
    "year": 2002,
    "authors": [
      "Axel Hacke"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3730
  },
  {
    "title": "MAXIMAS MINIMAS",
    "isbn": "9788470309168",
    "synopsis": "535 aforismos sobre el amor, la vida, la muerte, el hombre, la mujer, la moralidad, los padres y los hijos, la felicidad, la sinceridad, la inteligencia, el pudor, la política, el arte, la poesía, la música, el humor, el matrimonio, el trabajo, etc., sobre estos y otros temas que, por no ser de actualidad, están siempre de actualidad.",
    "year": 2001,
    "authors": [
      "Enrique Jardiel Poncela"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3874
  },
  {
    "title": "LOCA POR LAS COMPRAS",
    "isbn": "9788478886661",
    "synopsis": "Días soporíferos, noches frustrantes y nada en el horizonte necesitas algo que te levante el ánimo ¡ya! coges el bolso, compruebas la tarjeta de crédito y... ¡a comprar! Si uno acabara de conocer a Rebecca diría que es una chica como muchas otras, activa, alegre y con ganas de marcha. Pero si intentara compartir con ella un placentero e inocente sábado por la tarde, paseando por, digamos, King''s Road, constataría de inmediato que Becky, como la llaman sus amigos, está total, absoluta, perdida e irremisiblemente... ¡loca por las compras! Pese a sus denodados esfuerzos por controlar esos devastadores impulsos consumistas, Becky ha sucumbido tantas veces a la tentación que las deudas empiezan a volverse una seria amenaza para sus inmaculados antecedentes penales.",
    "year": 2001,
    "authors": [
      "Sophie Kinsella"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3955
  },
  {
    "title": "LA TABERNA DE EL TRAGA: SANTUARIO DE LA GRACIA",
    "isbn": "9788495122391",
    "synopsis": "La Taberna de El Traga es un libro que se bebe de un solo sorbo, no es una historia pero sí una historieta de la famosa taberna. En la que ha lugar un divertidísimo desfile de los personajes que la poblaron, gran parte de ellos que ya se fueron para siempre, integrantes del singular elenco de un monipodio de aquellos años, viva moneda que no se volverá a repetir: El Gringo, el Piripi, el Brillantina, el Cojo Peroche, el Silvestre, el Loqui, el Terrible, el Joseliqui, el Habichuela entre otros, colmaron de ángel la Taberna que aquí se presenta.",
    "year": 2000,
    "authors": [
      "Jose Antonio Garmendia"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3970
  },
  {
    "title": "RIURE PER VIURE: RECULL D''ACUDITS",
    "isbn": "9788495186058",
    "synopsis": "Un llibre divertir i seriós però sobre tot, solidari.Solidari perque limport dels drets dautor es destinen a finançar programes de suport als infants que pateixen càncer a Catalunya.Com recorda Carles Fisas al pròleg, el bon humor és una medicina, una forma de proveir-nos de benestar, que ens ajuda a viure millor el present i afrontar amb força i determinació alló que el futur ens porti.",
    "year": 1999,
    "authors": [
      "Carles Vives"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3975
  },
  {
    "title": "TINTO DE VERANO",
    "isbn": "9788403092372",
    "synopsis": "Este libro es la irónica crónica de un agosto de tintos de verano, escrita con frescura y sinvergonzonería. Y humor, muchísimo humor. Elvira Lindo juega con fuego y simula que escribe sobre sí misma, sobre su santo y la vida cotidiana durante las somnolientas tardes de verano en un pequeño pueblo de vacaciones. Y lo hace con tal habilidad literaria y tanta verosimilitud que muchos lectores creerán real lo que no es sino resultado del trabajo y la imaginación de la autora. Pero más allá del equívoco deliberado, de la sonrisa cómplice que provoca la lectura de estas páginas, al final descubrimos que el verdadero tema de este libro, es sencillamente, la felicidad.",
    "year": 2001,
    "authors": [
      "Elvira Lindo"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 3991
  },
  {
    "title": "EL SANTORAL DE LUIS CARANDELL",
    "isbn": "9788486478735",
    "synopsis": "La vida de nuestros santos escrita de forma simpática, educativa y amena. La cultura hagiográfica es poco conocida, y a pesar de estar muy arraigada en nuestra cultura popular, pocos de nosotros conocemos la vida y anécdotas de nuestros santos. Ahora, Luis Carandell con su magnífica pluma y Alfonso Ortuño con sus geniales ilustraciones a todo color, nos presentan la vida de nuestros santos de forma simpática, educativa y amena. En cada página se describe el santo más representativo del día y se incluyen también los nombres de otros santos que se celebran en el día. Cada mes contiene una ilustración, lámina a todo color que representa el santo más emblemático del mes. Contiene, además, un índice onomástico para que todos podamos saber el día que se celebra nuestro santo.Siguiendo las hagiografías antiguas, Carandell ha reescrito esta «Leyenda Dorada» que es parte esencial de nuestra herencia literaria.",
    "year": 1997,
    "authors": [
      "Luis Carandell"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4121
  },
  {
    "title": "LA LOCA FAMILIA TWERP",
    "isbn": "9788475159058",
    "synopsis": "A la muerte de una estrella de rock que ha dilapidado todo su dinero, sus tres hijos y su dinámica esposa sólo heredan una vieja casa medio derruida. Pero a pesar de su desgracia y de sus constantes apuros económicos, los Twerp saldrán adelante, aunque tengan que vérselas con el temido y odiado Killer Keast, director del colegio, con los sumisos y atemorizados profesores de la escuela, con ladrones que intentan desvalijar su casa y, sobre todo, con Rose, una policía, campeona nacional de revolcones en el barro, que se instala unos días en su casa... (A partir de 10 años.) Encuadernación: rústica.",
    "year": 1999,
    "authors": [
      "David Tinkler"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4187
  },
  {
    "title": "EL HOMBRE QUE NO PODIA VERSE A SI MISMO",
    "isbn": "9788478083268",
    "synopsis": "Todos buscamos el verdadero amor, pero ¿qué espera el Universo de nosotros? ¿Cómo podemos entregarnos y rendirnos totalmente para, de este modo, permitir que el Universo se nos revele indicándonos el camino a seguir? Lo que parecen obstáculos, muchas veces no son sino tropiezos mágicos. Desbordante de humor e inspiración, este relato nos da la respuesta. Con sus inocentes ilustraciones y la poética sencillez de sus textos, sin duda renovará tu fe en el inmenso poder del amor.",
    "year": 2000,
    "authors": [
      "Richard Torregrossa"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4233
  },
  {
    "title": "NI MUERTA NI CASADA",
    "isbn": "9788496693012",
    "synopsis": "Ha sido una semana de lo más movidita para Betsy Taylor. Primero, pierde su trabajo. Luego, para colmo, muere en un accidente de coche. Pero lo que realmente le molesta (además de despertar en la morgue vestida con un traje color rosa chicle y zapatos baratos, cortesía de su madrastra), es que no logra permanecer muerta. Todas las noches se levanta con un antojo terrible de sangre. Y la dieta líquida no le sienta demasiado bien.",
    "year": 2006,
    "authors": [
      "Mary Janice Davidson"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4400
  },
  {
    "title": "ASPECTOS SICOLOGICOS DEL CALZONCILLO Y OTROS ARTICULOS DE HUMOR",
    "isbn": "9789583600708",
    "synopsis": "¿Qué ocurre cuando un niño recoge en la calle chicles ya masticados y los chupa sin que la madre lo sepa? ¿Es posible el sexo después de los cincuenta años? ¿Cómo lidiar con un contestador telefónico que transmite la quinta sinfonía de Beethoven antes del tonito? ¿Cuál es la fórmula secreta para un matrimonio duradero? ¿Cómo, cuándo y dónde hay qué comprar calzoncillos? Una dieta a base de lechuga y baños de asiento, ¿adelgaza o mata? ¿Es un acto de buen gusto sonarse con un mantel blanco cuando usted lleva vestido azul?Estas y otras apasionantes preguntas son respondidas por el autor de la presente obra con su habitual franqueza, sabiduría, humor y aversión a la solemnidad.",
    "year": 2006,
    "authors": [
      "Daniel Samper Pizano"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4422
  },
  {
    "title": "PSIQUIATRAS PSICOLOGOS Y OTROS ENFERMOS",
    "isbn": "9788466368599",
    "synopsis": "Rodrigo Montalvo vive con su mujer, sus hijos y su gato, que lo quieren con locura. Tiene un chalet adosado, un buen coche y un trabajo que le gusta. Es un hombre feliz. O al menos eso ha creído siempre. Hasta que un buen día un psiquiatra le hace dudar. Nuestro héroe quiere saber qué le pasa y visita a esos seres empeñados en ocuparse de su cabeza, los psiquiatras, los psicólogos y otros enfermos, que aportan soluciones desternillantes y no dudan en saquear su cartera.Con esta hilarante novela que atrapa al lector desde la primera página. Rodrigo Muñoz Avia esconde tras el humor un análisi perturbador del alma moderna, de la imposición de la felicidad.",
    "year": 2006,
    "authors": [
      "Rodrigo Muñoz Avia"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4453
  },
  {
    "title": "HUMOR MEDICO: LAS MEJORES ANECDOTAS Y CHISTES SOBRE MEDICOS Y PAC IENTES",
    "isbn": "9788479277994",
    "synopsis": "La finalidad de estas páginas es entretener a unos y a otros. A fin de cuentas, también los médicos se convierten de vez en cuando en pacientes, aunque con algo de ventaja. Aquí se explican hechos reales y otros que bien pudieran serlo,cosas que pasan en los quirófanos, las consultas, las salas de espera y, en general, asuntos cómicos y estrafalarios sobre lo que se cuece tras las bambalinas de los hospitales y las clínicas. También se pone el dedo en la llaga de la profesionalidad y la ética médica, pero con el máximo cariño y con la intención de ahondar, de forma divertida, en cómo es de complejo el comportamiento humano.",
    "year": 2006,
    "authors": [
      "Arsenio Asenjo"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4454
  },
  {
    "title": "VORACIDAD",
    "isbn": "9788466629324",
    "synopsis": "Novela de humor e ironía, protagonizada por Pancho Murga, un bilbaíno pijo y buscavidas. Ambientada en la actualidad, entre Bilbao y Madrid, tiene como telón de fondo personajes reconocibles (con nombre supuesto) de la política, la televisión, personajes estrambóticos que sienten la ansiedad de la comida, pero también de consumir con voracidad todo lo que se les pone por delante. Humor negro que cuestiona los modelos de sociedad actuales.",
    "year": 2006,
    "authors": [
      "Juan Bas"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4473
  },
  {
    "title": "EL FONTANERO DEL CONGRESO",
    "isbn": "9788466628167",
    "synopsis": "Una inoportuna llamada de teléfono obliga a Franco Veleta, ex asesor de Jimmy Carter, a personarse en la Carrera de San Jerónimo. Manuel Marín quiere ser presidente del Gobierno y necesita a nuestro protagonista para cumplir su sueño dorado. Durante el relato, que concluye con las elecciones de 2008, veremos al ex ministro Bono a tortas con Evo Morales, a Condoleezza Rice asestándole un certero golpe de kárate a Letizia Ortiz, y al presidente Zapatero tan perdido como siempre.¿Es un cómic? ¿Es un delirio? No: es Franco Veleta, el Fontanero del Congreso, el hombre que tiene la llave de la Moncloa? y quién sabe si de la Zarzuela. Sólo una persona con ese nombre podría armar tanto revuelo?",
    "year": 2006,
    "authors": [
      "Willy Bowling"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4480
  },
  {
    "title": "CUENTOS CORTOS SURREALISTAS PARA NIÑOS DE SIETE A SETENTA AÑOS",
    "isbn": "9788461133512",
    "synopsis": "Para los que hoy pasamos de los sesenta recordamos con horror los cuentos que nos contaban nuestras madres y abuelas. \"Caperucita y el lobo\", \"El cabrito de el lobo que se comía a todo bicho viviente\", \"Los tres cerditos\", -hacían sus casitas, llegaba el lobo, soplaba, y las casitas se iban a hacer puñetas-, \"Hansel y Gretel\" -enseñaban un hueso para que creyeran que ya se habían comido a los niños-, \"El hombre del saco\", \"El Coco\". Yo recuerdo que me dormía bañado en sudor por el terror que me producían esos cuentos que sólo fomentaban el miedo. Los niños de ahora, no son como éramos nosotros. Son infinitamente más listos y ya nadie les cuenta aquellos espeluznantes relatos. Hay un vacío de cuentos desde hace ya bastante tiempo. Estos que yo he escrito, tienen hasta moraleja y son para los niños de ahora. Para que cuando se los cuenten, se rían y duerman sin miedos.",
    "year": 2006,
    "authors": [
      "Antonio Ozores Puchol"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4483
  },
  {
    "title": "MAGNICHISTES: LOS CHISTES DE LOS PERSONAJES FAMOSOS DE ESTE MUNDO Y DEL OTRO",
    "isbn": "9788479278304",
    "synopsis": "¿Qué tienen en común Ronaldinho y Moisés? ¿Michael Jackson y Saddam Hussein? ¿El Papa y la duquesa de Alba? ¿San José y Fidel Castro? ¿La reina de Inglaterra y Judas? ¿Satanás y Lady Di? La respuesta es sencilla: ¡todos ellos son protagonistas de multitud de chistes!Es una de las consecuencias de ser famoso. Da igual que seas una aspirante a santa como la Madre Teresa de Calcuta o un chiflado exterminador de seres humanos como Adolf Hitler. Si eres famoso, tienes ya muchos puntos para que se rían de ti. Y si además eres político, entonces no tienes escapatoria: hagas lo que hagas, vas a ser crucificado a chistes.",
    "year": 2006,
    "authors": [
      "Rocaviva"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4499
  },
  {
    "title": "LA SONRISA DE LA JUSTICIA",
    "isbn": "9788496632073",
    "synopsis": "Por los juzgados y tribunales desfila cada día, generalmente no de buen grado, una variopinta legión de personas que -on sus temores a cuestas, algunas también con su desenfado- dan lugar muchas veces a episodios que, pese a la sobriedad o a la solemnidad del marco, resultan de una irresistible jocosidad. No es raro que los profesionales del Derecho también se erijan, en ocasiones, en protagonistas de lances divertidos.",
    "year": 2006,
    "authors": [
      "Juan Camuñez Ruiz"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4514
  },
  {
    "title": "HUMOR LEGAL",
    "isbn": "9788479278663",
    "synopsis": "En el movido mundo de la justicia hay de todo, no sólo negligencias clamorosas e ignorancia profesional, sino también exceso de celo y buen criterio. Este libro da fe de ello y cuenta cosas destacables y cosas deplorables, pero siempre desternillantes, sobre los avatares legales. Tanto los administradores de justicia como los administrados encontrarán aquí sabias y pícaras estrategias para cada ocasión. Además, si es usted profesional de la justicia, descubrirá lo que realmente piensan los clientes sobre su función social y reirá con los errores más inverosímiles de sus compañeros de oficio o con las sentencias más insólitas de la historia. Éste es un libro sabio por lo real de las anécdotas que recoge, a veces de manera sutil, a veces de manera mordaz, sobre el insondable mundo de la justicia.",
    "year": 2006,
    "authors": [
      "Armando Bulla"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4519
  },
  {
    "title": "COMO NO TENGO NADA QUE DECIR, ¡LO DIRE SOLO UNA VEZ¡ (GAGS PARA E L ESCENARIO Nº 4): CHISTES BREVES BUENOS BUENOS",
    "isbn": "9788489749504",
    "synopsis": "Una impresionante recopilación de chistes, gags, bromas y frases o mini monólogos de dos líneas, de gran ingenio para todos aquellos que queráis añadir humor a vuestras presentaciones. Inventados, recopilados, tomados prestados o robados con el debido consentimiento, por Aldo Colombini, un monstruo del escenario, un mago que ha hecho reír en 45 países. ¿No sabes quién es Aldo? Pregunta a cualquier mago del mundo. Sencillamente un domador de públicos.",
    "year": 2005,
    "authors": [
      "Aldo Colombini"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4539
  },
  {
    "title": "GRAN ENCICLOPEDIA DEL HUMOR: LOS 999 MEJORES CHISTES DE LA HISTOR IA",
    "isbn": "9788466316736",
    "synopsis": "¿Saben de aquel que diu.?Ha habido que esperar, pero, finalmente, el humor ocupa el lugar que, como saber enciclopédico, se merece. Una antología con los 999 mejores chistes de la historia, en la que no se salva ni el apuntador. Porque cualquier situación, cualquier personaje, puede acabar siendo el objeto de un chiste. Pero no importa: la risa alarga la vida.",
    "year": 2005,
    "authors": [
      "Pablo Nacach"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4553
  },
  {
    "title": "LOS MEJORES CHISTES 2",
    "isbn": "9789500298414",
    "synopsis": "No hay nada más grato que contar chistes. Además, ser el más ingenioso y divertido de la reunión, nos levanta el ánimo y la autoestima. Pues bien, ¿cómo se hace para lograr esto?, Muy sencillo: debe contar con una buena batería de chistes, y la encontrará en este libro que es una excelente recopilación de chistes para toda ocasión. Una fiesta familiar, un casamiento, una despedida de soltero y numerosas otras situaciones.",
    "year": 2006,
    "authors": [
      "Julio Cesar Parissi"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4600
  },
  {
    "title": "EL DISCRETO ENCANTO DEL LIGUERO Y OTROS MOTIVOS PARA SONREIR",
    "isbn": "9789583601033",
    "synopsis": "Entre muchas otras razones, este libro pasará a la historia de las letras porque en sus páginas nace un nuevo género literario: el suspenso erótico, concentrado en las vicisitudes de un tímido adolescente que comparte por un tiempo la oficina de una mujer muy atractiva cuyas prendas íntimas se asoman, de manera inquietante, por debajo de la falda. Con telanto incombustible y explotando vetas escondidas de su memoria, el autor recrea para los lectores un episodio inédito que suscitara en dios intriga, pasión, angustia, lascivia, tensión, deleite, morbo, excitación y expectativa.",
    "year": 2006,
    "authors": [
      "Daniel Samper Pizano"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4624
  },
  {
    "title": "ANTROPOLOGIA Y SU SUEGRA",
    "isbn": "9788496560352",
    "synopsis": "Un antropólogo y su suegra: antología de la diversidad y del conflicto, es un libro obligado para todos aquellos que, teniendo suegra, se asombren ante su quehacer cotidiano, reflejando, en tono de humor, los espacios alejados entre estas categorías sociales. Cada una de ellas es la síntesis de dualidades encontradas en el autor y su suegra: joven-mayor, hombre-mujer, rural-urbano, rico-pobre, conservador-progresista, religiosidad pública-religiosidad intimista…, ello hizo que la convivencia -que la hubo- fuera un mero azar de posibilidades encontradas. El texto tiene la magia de encontrarse en la misma complejidad de nuestra cultura, en la búsqueda continua del equilibrio ante la familia política ideada para el apoyo mutuo pero alejada en el común de los casos y con innumerables obstáculos que salvar.",
    "year": 2007,
    "authors": [
      "Domingo Barbolla Camarero"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4688
  },
  {
    "title": "SOBREVIVIR A UNA MUTACION",
    "isbn": "9788461188628",
    "synopsis": "Sobrevivir a una Mutación es una visión irónica y descreída del universo de los discapacitados físicos. Desde la parodia a los libros de autoayuda, y con la jerga del cómic como referente, El Diablo sobre Ruedas, Mutante experimentado, ofrece a otros Mutantes, claves para sobrevivir en un entorno creado por y para Humanoides, y a los Humanoides, pistas para comprender cómo es eso de ver el mundo desde un \"Mutanmóvil\".",
    "year": 2007,
    "authors": [
      "Luis Silva"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4730
  },
  {
    "title": "HOMBRES CON LOS QUE NO ME CASE",
    "isbn": "9788466630245",
    "synopsis": "El marido de Hallie le anuncia por sorpresa que la deja por una guapísima entrenadora personal. Después de recuperarse de un atracón de galletas de chocolate que casi la deja en coma, Hallie decide tomar las riendas de su vida. Una llamada inesperada de un antiguo novio de la universidad pone en marcha un plan. ¿Qué ha sido de todos esos hombres con los que no se casó? Todas nos preguntamos a cierta altura de la vida qué habría ocurrido si nos hubiéramos casado con otro... En esta divertida comedia romántica, acompañamos a Hallie mientras se reencuentra con sus viejos amores para buscar respuesta a esta pregunta.",
    "year": 2007,
    "authors": [
      "Janice Kaplan"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4750
  },
  {
    "title": "HAZAÑAS DEL CAPITAN CARPETO",
    "isbn": "9788466368957",
    "synopsis": "Vestido con leotardos y capa y con un orinal en la cabeza a modo de casco, convertido en un superhéroe que se llama capitán Carpeto: así termina un apacible viudo que pierde el juicio por la lectura compulsiva de cómics... Conspiraciones y batallas, superpoderes, mutantes, disparates sin cuento en un desternillante homenaje al Quijote que se publicó por entregas en el diario 20 minutos y que constituye, como su referente, una crítica mordaz a la sociedad contemporánea.",
    "year": 2007,
    "authors": [
      "Rafael Reig"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4772
  },
  {
    "title": "!PUAF,QUE ASCO!: UNA VISION ILUSIONADA DEL MUNDO",
    "isbn": "9788496797000",
    "synopsis": "¿Es mejorable la humanidad?: Sí, siempre que la devolvamos al remitente y nos envíen otra distinta. Salir adelante con lo puesto da la sensación de que va a ser verdaderamente difícil. Crítica mordaz sobre el mundo del espectáculo, la farándula y todo lo que a esto rodea y que entretiene al \"gran público\" pero hace que la hipocresía se convierta en un hábito del que resulta imposible desprenderse. Para el autor existen pocos elementos tan imprescindibles para la supervivencia como el sentido del humor. A veces negro, muy negro, pero es el único medio, relativamente amable, con el que poder acercarse a la realidad del despropósito planetario en el que habitamos.",
    "year": 2007,
    "authors": [
      "Luis Lorente"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4798
  },
  {
    "title": "TENGO UN MANNY EN CASA",
    "isbn": "9788466631747",
    "synopsis": "Jamie está casada desde hace doce con un abogado de gran éxito y trabaja a tiempo parcial como periodista de investigación. Su marido presta muy poca atención a sus hijos, por lo que Jamie decide contratar a un manny: un niñero que se encargue de llevar a su hijo Dylan a hacer las cosas típicas que haría con su padre. Y entonces la situación empieza a complicarse... Una novela entretenida y llena de sorpresas, que además permite vislumbrar la vida cotidiana de los privilegiados de Park Avenue, el enclave más chic de Manhattan.",
    "year": 2007,
    "authors": [
      "Holly Peterson"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4833
  },
  {
    "title": "LA TIENDA DE LOS SUICIDAS",
    "isbn": "9788402420541",
    "synopsis": "Novela enormemente divertida, no exenta de humor negro, en la que el lector penetra en la tienda y en la vida de una familia dedicada a la venta de productos (sogas para ahorcarse, venenos de toda índole, armas, etc,) que cualquier suicida deber tener a mano para el momento en que decida abandonar este mundo. La familia se siente orgullosa de su trabajo y su reconocida eficacia profesional, hasta que en su seno nace una nueva criatura: un niño alegre al que entusiasma la risa.Es una novela muy divertida, ágil, bien escrita, con diálogos chispeantes.",
    "year": 2008,
    "authors": [
      "Jean Teule"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4870
  },
  {
    "title": "LA ADUANA DEL CIELO",
    "isbn": "9788496790353",
    "synopsis": "La aduana del cieloes una novela evocativa. Don Jesús Manzano, sacerdote jubilado y enfermo, relata con nostalgia el tiempo que pasó como capellán en la finca Los Tres Álamos situada en Morón de la Frontera (Sevilla). Revive aquellos años, 1957 a 1969, y a susextravagantes trabajadores. Y por supuesto, a sus propietarios, Muy especialmente a la “Señorita”: doña Anunciación de la Virgen María y sus asfixiantes maneras de conquistar aquellas almas para el Reino de los Cielos. Estamos ante una novela coral: los trabajadores más significativos de aquella finca, desfilan ante el lector mostrando sus sombras y luces. En la segunda parte, describe los hechos más insólitos que el sacerdote vivió durante su estancia en la finca. La Aduana del Cielo es un fiel retrato de la mentalidad religiosa de aquella época, adornado con altas dosis de humor.",
    "year": 2007,
    "authors": [
      "Manuel Leon Mejias"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4873
  },
  {
    "title": "DON CAMILO Y COMPAÑIA",
    "isbn": "9788493643348",
    "synopsis": "Don Camilo es un libro que se lee de principio a fin con una sonrisa en los labios. Es un ejemplo de equilibrio, quizá perfecto, entre comicidad y ternura. Una novela cómica que va mucho más a allá de la caricatura. A aquellos que ya hayan leído la novela, está nueva traducción realizada en el centenario del nacimiento del autor les permitirá volver a disfrutar de las chispeantes, ingeniosas y frescas conversaciones entre el inolvidable cura Don Camilo y su antagonista, el comunista Pepone. Y los que se enfrentan por vez primera a estos diálogos, se encontrarán con la quintaesencia del humor italiano en estado químicamente puro; un humor que les asaltará desde un rincón, siempre inopinado. Les ocurrirá aquello que Borges decía de Chesterton, que “en cada página habita una felicidad”.",
    "year": 2008,
    "authors": [
      "Giovanni Guareschi"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4919
  },
  {
    "title": "VADEMECUM DE REMEDIOS IMAGINARIOS",
    "isbn": "9789876090162",
    "synopsis": "¿Era el doctor W. Hans von Trötten un desequilibrado mental, sin el menor rigor científico? ¿O era, por el contrario, un investigador sobresaliente, cuyos descubrimientos estaban a punto de cambiar para siempre los presupuestos médicos más elementales? Afortunadamente, el trabajo riguroso de peritos y calígrafos, dedicados durante décadas a descifrar escritos en clave y anotaciones tan abigarradas como iluminadoras, permitió rescatar del olvido y la destrucción las páginas que hoy forman este Vademécum. Supositorios contra la arrogancia, jarabes que desatan los nudos de la garganta y pastillas que combaten la depresión del domingo a la noche son sólo algunos de los numerosos remedios que pueblan las páginas de este Vademécum, prolijamente descriptos con su acción terapéutica, su composición, su posología, sus efectos colaterales y sus contraindicaciones.",
    "year": 2007,
    "authors": [
      "Ricardo Andrada"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 4969
  },
  {
    "title": "DIARIO DE UN NINJA",
    "isbn": "9788466369749",
    "synopsis": "Tenía 3 años cuando salvé un pavo que mi padre había robado para cenar en Nochebuena. Entonces comprendí que había nacido para hacer el bien. Con 18 me expulsaron del colegio, lo que hizo que orientara mi vida hacia el ejército, aunque no me admitieron porque no había gorras de mi talla. Diez años después y debido a mi ausencia de actividad laboral, mi padre me echa de casa por segunda vez (la primera fue cuando salvé el pavo). Sin embargo, un curso por correspondencia cambió mi vida, pues estudié para ser guerrero ninja y lo conseguí. Una vez lograda mi meta, comencé con mi misión, la de defender a mis conciudadanos de todo mal. Pero que quede bien claro que no me creo un superhéroe: soy un ninja, el primero que decide publicar sus hazañas en una autobiografía.",
    "year": 2007,
    "authors": [
      "Miguel Angel Rodriguez"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5011
  },
  {
    "title": "L UNIC SECRET QUE REALMENT CANVIARA LA TEVA VIDA",
    "isbn": "9788466410281",
    "synopsis": "Una hilarant paròdia dels grans ‘best-sellers’ internacionals d’autoajuda. Aquest llibre canviarà la teva vida. La canviarà realment, del tot, segur. Mira el cel i dóna les gràcies per tenir aquest llibre a les mans. Per aquest fragment de segon en el qual els teus ulls s’han fixat en la coberta. Creus que és casualitat? No, és el destí. El destí ha portat aquest llibre a les teves mans per donar-te una oportunitat. Per ser allò que sempre has volgut ser, per canviar el que sempre has volgut canviar, per triomfar on sempre has fracassat. Perquè aquest llibre conté l’Únic Secret. L’Únic Secret no té res a veure amb El Secret, ni amb el Gran Secret, ni amb el Secret Il•luminador, ni encara menys amb l’Extraordinari Secret que Caurà Com Una Llum Sobre Teu. No, no, tot això que has llegit abans no és més que fantasia i xerrameca per a ximplets que s’ho creuen tot.",
    "year": 2009,
    "authors": [
      "John R. Gold"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5108
  },
  {
    "title": "NI MUERTA NO VALORADA",
    "isbn": "9788496693210",
    "synopsis": "CONTINUA LA SAGA DE LA VAMPIRESA MÁS ALOCADA¿Te vas a quedar con las ganas? Su autora está considerada como una de las mejores autoras según el New York Times y el USA Today Best Selling. Autora que irrumpió en la escena del romanticismo paranormal hace tres años con su primer libro de su ya popular y consolidada serie de Ni muerta ni… (Undead series).",
    "year": 2008,
    "authors": [
      "Mary Janice Davidson"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5140
  },
  {
    "title": "HABLANDO MAL DE...",
    "isbn": "9788479278953",
    "synopsis": "¿Alguien duda del dicho según el cual «la mejor defensa es un ataque»? El autor de esta antología del escarnio y el insulto no tiene ninguna duda. Guiado por la firme convicción de que corren tiempos en los que conviene llevar armadura para estar en sociedad, El Descosío ha compendiado y comentado sin ningún recato ni miramiento un auténtico tesoro de citas llenas de agudeza y crueldad inteligente. Tanto los personajes a los que pertenecen las citas como a los que van dirigidas, unas veces ilustres y otras no tan conocidos, quedan aquí retratados con mucha más fidelidad que en cualquier biografía al uso. Templado en la fragua del desenfado más provocador, Hablando mal de... no es sólo un libro para saber quién dijo qué de quién, sino también un sugeridor consejero para la autodefensa dialéctica más sofisticada.",
    "year": 2007,
    "authors": [
      "El Descosio"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5154
  },
  {
    "title": "POR UN PUÑADO DE POLVOS",
    "isbn": "9788415584674",
    "synopsis": "Txomin es un joven cuarentón a quien abandona su pareja. Sintiéndose libre, decide experimentar diferentes formas de conquista femenina para poder escribir la biblia del playboy vasco, un compendio de métodos infalibles de ligoteo. Sin embargo no cuenta con la dificultad extrema que presenta la mujer vasca. El libro cuenta de forma satírica con un humor en ocasiones ácido, las desventuras de Txomín en su travesía a través de diferentes formas de acercamiento a la mujer, desde el cuerpo a cuerpo hasta las redes sociales, en su afán por alcanzar una quimera inalcanzable: la cópula con una vasca.",
    "year": 2013,
    "authors": [
      "Domingo Plumaroja"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5203
  },
  {
    "title": "DONDE LOS TOROS TIENEN LOS OJOS VERDES",
    "isbn": "9788408099178",
    "synopsis": "Aunque el título afirme lo contrario, no existen toros con los ojos verdes. Pero si existieran, sólo podrían criarse en Andalucía la Baja. Allí se extiende La Jaralera, magnífico cortijo propiedad de los Sotoancho, familia creada por el escritor Alfonso Ussía. Es un enclave ajeno al mundo que lo rodea, regido por sus propias normas y por sus costumbres ancestrales, y habitado por una serie de personajes excepcionales, como son el propio Marques de Sotoancho y su madre. Sobre esos personajes y las aventuras, algo domesticas y bastante absurdas que viven, Juan Carlos Sánchez Samper ha realizado un estudio en el que no falta un detalle.",
    "year": 2011,
    "authors": [
      "Juan Carlos Sanchez Samper"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5228
  },
  {
    "title": "LOS MEJORES CHISTES DEL MUNDO 3",
    "isbn": "9788479279219",
    "synopsis": "Por suerte, el humor continúa siendo una de las más poderosas armas contra la locura en este mundo nuestro. Reírse de todo, hasta de uno mismo, desde el respeto y dentro de la oportunidad y el contexto adecuado es una muestra de salud mental. En este desternillante volumen le aguarda el más valioso tratamiento antiestrés: cientos de chistes con los que no podrá reprimir la carcajada.",
    "year": 2007,
    "authors": [
      "Samuel Red"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5300
  },
  {
    "title": "DIARIO DE UNA MISS INTELIGENTE",
    "isbn": "9788496693050",
    "synopsis": "El autor crea un personaje y lo dota de vida. A lo largo del desarrollo del blog, ésta será una de las premisas fundamentales para él: conseguir que el público crea que realmente existe, que no es una creación de nadie. Se trata de una supuesta miss de cualquier provincia (que el autor mantiene hasta el final en absoluto anonimato) que acaba de perder en el concurso de Miss España. A través del blog, y a modo de diario, hará partícipe de sus inquietudes, de su llegada a Madrid para intentar triunfar. El título, Diario de una miss intelijente, no es más que una socarrona ironía acerca de este personaje, puesto que la miss nos va mostrando una personalidad estulta, ingenua, inculta e incluso paleta. Los garrafales (y voluntarios por parte del autor para dar credibilidad a su personaje) errores gramaticales y ortográficos salpican la obra desde el principio, y es éste uno de los elementos que más choca y da que hablar al público.",
    "year": 2006,
    "authors": [
      "Arturo Vallejo"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5310
  },
  {
    "title": "LO QUE DIOS HA UNIDO QUE NO LO SEPARE MAMA; PACHUCHA TIRANDO AL M AR: MEMORIAS DEL MARQUES DE SOTOANCHO",
    "isbn": "9788466607131",
    "synopsis": "Memorias del marqués de Sotancho. La albariza de los juncos es el diario completo del marqués con ilustraciones en acuarela de Barca. El marqués de Sotoancho, el personaje más importante de los creados por Alfonso Ussía, es un niño grande, caricatura del señorito andaluz, que provocará nuevas carcajadas en el lector con las situaciones insólitas en las que se verá envuelto. El secuestro de Mamá, relato inédito de Ussía, coloca a cada personaje en su lugar, especialmente a los protagonistas, Susú y Mamá. Sus mezquindades, sus picardías, sus obsesiones y temores están retratados con la claridad y el humor a que nos tiene acostumbrados el autor.",
    "year": 2001,
    "authors": [
      "Alfonso Ussia"
    ],
    "categories": [
      "Narrativa de humor"
    ],
    "source": "https://www.kaggle.com/datasets/danielalbarracinm/books-with-isbn-of-different-genres",
    "source_row": 5370
  }
]';
DECLARE @target INT = 500;
SELECT j.* INTO #Input FROM OPENJSON(@data)
WITH (title NVARCHAR(200), isbn CHAR(13), synopsis NVARCHAR(1000),
      year SMALLINT, authors NVARCHAR(MAX) AS JSON,
      categories NVARCHAR(MAX) AS JSON, source NVARCHAR(1000)) AS j;
IF (SELECT COUNT(*) FROM #Input)<>@target THROW 50102, N'Cantidad de libros incorrecta.', 1;
IF EXISTS(SELECT title FROM #Input GROUP BY title HAVING COUNT(*)>1)
 OR EXISTS(SELECT isbn FROM #Input GROUP BY isbn HAVING COUNT(*)>1)
 THROW 50103, N'Hay duplicados según la collation de SQL Server. Revisar los datos.', 1;
-- No confundir ISBN coincidente con título distinto, ni viceversa.
IF EXISTS (SELECT 1 FROM #Input i JOIN dbo.Books b ON b.Isbn=i.isbn OR b.Title=i.title
           WHERE b.Isbn<>i.isbn OR b.Title<>i.title)
 THROW 50104, N'Conflicto de ISBN/título con el catálogo. No se ha importado nada.', 1;
DECLARE @existing INT=(SELECT COUNT(*) FROM #Input i JOIN dbo.Books b ON b.Isbn=i.isbn AND b.Title=i.title);
IF @existing NOT IN (0,@target)
 THROW 50105, N'Coincidencia parcial con el catálogo: revisar antes de cargar.', 1;

-- Reserva nombres de prueba para no reutilizar personas existentes.
IF @existing=0 AND EXISTS(SELECT 1 FROM dbo.Members WHERE LoginName LIKE N'bench500[_]%'
                         OR Email LIKE N'bench500[_]%@example.com'
                         OR FullName LIKE N'Socio prueba 500 - %')
 THROW 50106, N'Los nombres de socios de prueba ya existen.', 1;

DECLARE @beforeBooks INT=(SELECT COUNT(*) FROM dbo.Books),
        @beforeMembers INT=(SELECT COUNT(*) FROM dbo.Members);
BEGIN TRY
 BEGIN TRANSACTION;
 IF @existing=0
 BEGIN
  INSERT dbo.Books(Title,Isbn,Synopsis,PublishedYear)
  SELECT title,isbn,synopsis,year FROM #Input;

  INSERT dbo.Authors(FullName)
  SELECT DISTINCT a.value FROM #Input i CROSS APPLY OPENJSON(i.authors) a
  WHERE NOT EXISTS(SELECT 1 FROM dbo.Authors x WHERE x.FullName=a.value);
  INSERT dbo.BookAuthors(BookId,AuthorId)
  SELECT DISTINCT b.BookId,a.AuthorId FROM #Input i
  JOIN dbo.Books b ON b.Isbn=i.isbn CROSS APPLY OPENJSON(i.authors) v
  JOIN dbo.Authors a ON a.FullName=v.value;

  -- Categorías de la fuente, sin inventar géneros. Conservar hasta 50 caracteres.
  -- El JSON original y fuentes.json retienen el texto completo.
  INSERT dbo.Genres(Name)
  SELECT DISTINCT LEFT(c.value,50) FROM #Input i CROSS APPLY OPENJSON(i.categories)c
  WHERE NOT EXISTS(SELECT 1 FROM dbo.Genres g WHERE g.Name=LEFT(c.value,50));
  INSERT dbo.BookGenres(BookId,GenreId)
  SELECT DISTINCT b.BookId,g.GenreId FROM #Input i JOIN dbo.Books b ON b.Isbn=i.isbn
  CROSS APPLY OPENJSON(i.categories)c JOIN dbo.Genres g ON g.Name=LEFT(c.value,50);

  ;WITH N AS (SELECT TOP(50) ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) n
              FROM sys.all_objects)
  INSERT dbo.Members(FullName,Email,LoginName)
  SELECT CONCAT(N'Socio prueba 500 - ',RIGHT('000'+CAST(n AS VARCHAR(3)),3)),
         CONCAT(N'bench500_',RIGHT('000'+CAST(n AS VARCHAR(3)),3),N'@example.com'),
         CONCAT(N'bench500_',RIGHT('000'+CAST(n AS VARCHAR(3)),3)) FROM N;

  -- Un perfil de categoría por socio, con 30 libros distintos.
  -- Afinidad por género cuando hay suficientes; relleno determinista del resto.
  SELECT g.GenreId,ROW_NUMBER() OVER(ORDER BY g.GenreId) rn INTO #Genres
  FROM dbo.Genres g WHERE EXISTS (SELECT 1 FROM dbo.BookGenres bg
    JOIN dbo.Books b ON b.BookId=bg.BookId JOIN #Input i ON i.isbn=b.Isbn
    WHERE bg.GenreId=g.GenreId);
  DECLARE @ng INT=(SELECT COUNT(*) FROM #Genres);
  ;WITH M AS (
   SELECT MemberId,ROW_NUMBER() OVER(ORDER BY LoginName) rn
   FROM dbo.Members WHERE LoginName LIKE N'bench500[_]%'
  )
  SELECT m.MemberId,b.BookId,b.Isbn,
    CASE WHEN EXISTS(SELECT 1 FROM dbo.BookGenres bg JOIN #Genres g ON g.GenreId=bg.GenreId
      WHERE bg.BookId=b.BookId AND g.rn=1+((m.rn-1)%NULLIF(@ng,0))) THEN 0 ELSE 1 END AS Preferencia
  INTO #Candidates
  FROM M m CROSS JOIN #Input i JOIN dbo.Books b ON b.Isbn=i.isbn;
  ;WITH Ranked AS (
   SELECT MemberId,BookId,
     ROW_NUMBER() OVER(PARTITION BY MemberId ORDER BY Preferencia,
       HASHBYTES('SHA2_256',CONCAT(MemberId,N':',Isbn)),BookId) pos
   FROM #Candidates
  )
  SELECT MemberId,BookId,pos INTO #Selected FROM Ranked WHERE pos<=30;

  IF (SELECT COUNT(*) FROM #Selected)<>1500
   THROW 50109,N'No se pudieron preparar los 1500 préstamos.',1;
  INSERT dbo.Loans(BookId,MemberId,LoanDate,ReturnDate,Status)
  SELECT BookId,MemberId,
    DATEADD(DAY,-10-2*CAST(ROW_NUMBER() OVER(PARTITION BY BookId ORDER BY MemberId) AS INT),CAST(GETDATE() AS DATE)),
    DATEADD(DAY,-9-2*CAST(ROW_NUMBER() OVER(PARTITION BY BookId ORDER BY MemberId) AS INT),CAST(GETDATE() AS DATE)),
    'Terminado'
  FROM #Selected;
  INSERT dbo.Ratings(BookId,MemberId,Score,Comment)
  SELECT BookId,MemberId,CASE WHEN pos<=15 THEN 5 WHEN pos<=23 THEN 4
                            WHEN pos<=27 THEN 3 ELSE 2 END,
         N'Valoración sintética para pruebas de rendimiento; no es una opinión real.'
  FROM #Selected;
 END;
 -- Preparar textos de los nuevos libros; no tocar los originales.
 UPDATE b SET EmbeddingText=CONCAT(N'Título: ',c.Title,N'. Autor: ',c.Authors,
      N'. Géneros: ',c.Genres,N'. Sinopsis: ',c.Synopsis)
 FROM dbo.Books b JOIN #Input i ON i.isbn=b.Isbn
 JOIN dbo.vw_BookCatalog c ON c.BookId=b.BookId
 WHERE b.Embedding IS NULL AND b.EmbeddingText IS NULL;
 IF (SELECT COUNT(*) FROM #Input i JOIN dbo.Books b ON b.Isbn=i.isbn)<>@target
  THROW 50107, N'La carga no contiene todos los libros.', 1;
 IF (SELECT COUNT(*) FROM dbo.Members WHERE LoginName LIKE N'bench500[_]%')<>50
  THROW 50108, N'No hay exactamente 50 socios de prueba.', 1;
 COMMIT;
 SELECT (SELECT COUNT(*) FROM dbo.Books)-@beforeBooks AS LibrosAgregados,
        (SELECT COUNT(*) FROM dbo.Members)-@beforeMembers AS SociosAgregados;
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK;
 THROW;
END CATCH;
SELECT COUNT(*) AS Libros,COUNT(Embedding) AS ConEmbedding FROM dbo.Books;
SELECT COUNT(*) AS Socios FROM dbo.Members;
-- Si partías de 15 libros y 4 socios: 515 libros y 54 socios.
DROP TABLE IF EXISTS #Input, #Genres, #Selected, #Candidates;
GO
