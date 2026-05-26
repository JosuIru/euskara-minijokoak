import 'kantua.dart';

/// Catálogo inicial de canciones para el módulo de Hutsuneak.
///
/// Solo usamos canciones tradicionales / populares de larga circulación
/// (sin autoría reciente claramente identificable) para evitar problemas
/// de derechos en el MVP. Cuando AEK confirme un acuerdo o el usuario
/// adquiera derechos, podremos añadir piezas modernas.
const List<Kantua> kantutegiaInicial = <Kantua>[
  Kantua(
    identificador: 'ikusi_mendizaleak',
    izenburua: 'Ikusi mendizaleak',
    egileaEdoIturria: 'Herri-kantua',
    azalpenLaburra:
        'Mendizaleek askotan kantatzen duten doinu tradizional ezaguna. '
        'A1-A2 mailako hiztegia: mendiak, eguzkia, herriak.',
    urlYoutube: 'https://www.youtube.com/results?search_query=ikusi+mendizaleak',
    versoak: <List<FragmentoVerso>>[
      <FragmentoVerso>[
        FragmentoVerso.texto('Ikusi '),
        FragmentoVerso.hueco('mendizaleak'),
        FragmentoVerso.texto(','),
      ],
      <FragmentoVerso>[
        FragmentoVerso.texto('hor goian zer '),
        FragmentoVerso.hueco('dagoen'),
        FragmentoVerso.texto('.'),
      ],
      <FragmentoVerso>[
        FragmentoVerso.hueco('Eguzkia'),
        FragmentoVerso.texto(' ageri da,'),
      ],
      <FragmentoVerso>[
        FragmentoVerso.texto('mendiaren '),
        FragmentoVerso.hueco('gainean'),
        FragmentoVerso.texto('.'),
      ],
    ],
    distraktoreak: <String>['ibaian', 'azpian', 'itsasoa', 'ikaslea'],
  ),
  Kantua(
    identificador: 'boga_boga',
    izenburua: 'Boga boga',
    egileaEdoIturria: 'Herri-kantua (marinela)',
    azalpenLaburra:
        'Itsasgizonen kantu tradizional ezaguna. Itsasoarekin lotutako '
        'hiztegia eta aginte-aditzak praktikatzeko.',
    urlYoutube: 'https://www.youtube.com/results?search_query=boga+boga+kantua',
    versoak: <List<FragmentoVerso>>[
      <FragmentoVerso>[
        FragmentoVerso.hueco('Boga'),
        FragmentoVerso.texto(' boga,'),
      ],
      <FragmentoVerso>[
        FragmentoVerso.texto('mariñela '),
        FragmentoVerso.hueco('mariñela'),
        FragmentoVerso.texto('.'),
      ],
      <FragmentoVerso>[
        FragmentoVerso.texto('Joan behar '),
        FragmentoVerso.hueco('dugu'),
        FragmentoVerso.texto(','),
      ],
      <FragmentoVerso>[
        FragmentoVerso.texto('urrutira, '),
        FragmentoVerso.hueco('urrutira'),
        FragmentoVerso.texto('.'),
      ],
    ],
    distraktoreak: <String>['etxera', 'dator', 'ibili', 'mendira'],
  ),
  Kantua(
    identificador: 'olentzero',
    izenburua: 'Olentzero',
    egileaEdoIturria: 'Herri-kantua (Gabonetakoa)',
    azalpenLaburra:
        'Gabonetan euskal herri guztietan kantatzen den abesti tradizionala. '
        'A1 mailako hiztegia: koloreak, jaiak, familia.',
    urlYoutube: 'https://www.youtube.com/results?search_query=olentzero+kantua',
    versoak: <List<FragmentoVerso>>[
      <FragmentoVerso>[
        FragmentoVerso.hueco('Olentzero'),
        FragmentoVerso.texto(' joan zaigu'),
      ],
      <FragmentoVerso>[
        FragmentoVerso.texto('mendira '),
        FragmentoVerso.hueco('lanera'),
        FragmentoVerso.texto(','),
      ],
      <FragmentoVerso>[
        FragmentoVerso.texto('intentzioarekin '),
        FragmentoVerso.hueco('ikatza'),
      ],
      <FragmentoVerso>[
        FragmentoVerso.texto('egitera.'),
      ],
    ],
    distraktoreak: <String>['etxera', 'eguzkia', 'haurra', 'ogia'],
  ),
];
