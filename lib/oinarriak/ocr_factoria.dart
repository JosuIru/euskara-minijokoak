import 'ocr_servicioa.dart';
// Conditional import: en builds web carga la implementación con
// Tesseract.js; en builds Android/iOS/desktop carga la de Google ML
// Kit. Sólo una de las dos llega al bundle final.
import 'ocr_tesseract.dart'
    if (dart.library.io) 'ocr_mlkit.dart' as impl;

/// Devuelve la implementación de [ServicioOcr] adecuada a la
/// plataforma actual. Los llamadores nunca deberían importar las
/// implementaciones concretas — todo va por aquí.
ServicioOcr crearServicioOcr() => impl.crearServicioOcrImpl();
