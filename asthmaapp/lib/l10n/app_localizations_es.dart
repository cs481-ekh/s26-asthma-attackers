// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Asesor de Actividad para el Asma';

  @override
  String get menuAbout => 'Acerca de';

  @override
  String get menuLanguage => 'Idioma';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionChange => 'Cambiar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get homeHeroTitle => 'Una app para guerreros del asma';

  @override
  String get homeHeroSubtitle =>
      'Consulta la calidad del aire y obtén ideas de actividad según cómo se sienta tu hijo hoy.';

  @override
  String get symptomLevelTitle => 'Nivel de síntomas del niño';

  @override
  String get selectSymptomLevel => 'Seleccionar nivel de síntomas';

  @override
  String get symptomSelectTitle => 'Seleccionar nivel de síntomas';

  @override
  String get symptomSelectSubtitle =>
      'Elige la opción que mejor describa los síntomas respiratorios o de asma actuales del niño.';

  @override
  String get confirmSelection => 'Confirmar selección';

  @override
  String get locationTitle => 'Ubicación para la calidad del aire';

  @override
  String get locationHelperWeb =>
      'Ingresa un código ZIP o el nombre de una ciudad (requerido en la web). ';

  @override
  String get locationHelperMobile =>
      'Usa la ubicación del dispositivo o ingresa un ZIP o ciudad. ';

  @override
  String get moreDetails => 'Más detalles';

  @override
  String get usingYourLocation => 'Usando tu ubicación';

  @override
  String get zipOrCityLabel => 'Código ZIP o ciudad';

  @override
  String get zipOrCityHint => 'p. ej., 83702 o Boise';

  @override
  String get useMyLocation => 'Usar mi ubicación';

  @override
  String get gettingLocation => 'Obteniendo ubicación…';

  @override
  String get getRecommendation => 'Obtener recomendación de actividad';

  @override
  String get snackSelectSymptomFirst =>
      'Primero selecciona un nivel de síntomas.';

  @override
  String get snackEnterZipOrCityWeb =>
      'Ingresa un ZIP o ciudad para obtener la calidad del aire.';

  @override
  String get snackEnterZipOrCityMobile =>
      'Usa \"Usar mi ubicación\" o ingresa un ZIP o ciudad para obtener la calidad del aire.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get recommendationTitle => 'Recomendación de actividad';

  @override
  String get goBack => 'Volver';

  @override
  String get currentLocation => 'Ubicación actual';

  @override
  String get loadingLocation => 'Cargando ubicación';

  @override
  String get locationServicesDisabled =>
      'Los servicios de ubicación están desactivados. Actívalos en la configuración del dispositivo.';

  @override
  String get locationPermissionDenied =>
      'Se denegó el permiso de ubicación. Ingresa un código ZIP o ciudad.';

  @override
  String get locationPermissionDeniedForever =>
      'La ubicación fue denegada permanentemente. Ingresa un código ZIP o ciudad.';

  @override
  String get locationFetchFailed =>
      'No se pudo obtener la ubicación. Inténtalo de nuevo o ingresa un código ZIP o ciudad.';

  @override
  String get validationEnterZipOrCity =>
      'Ingresa un código ZIP o el nombre de una ciudad.';

  @override
  String get validationInvalidZipOrCity =>
      'Ingresa un código ZIP válido de 5 dígitos (p. ej., 83702) o una ciudad (p. ej., Boise).';

  @override
  String get symptomALabel => 'Sin síntomas respiratorios o de asma';

  @override
  String get symptomBLabel => 'Pocos síntomas respiratorios o de asma';

  @override
  String get symptomCLabel => 'Síntomas respiratorios o de asma diarios';

  @override
  String get symptomADescription =>
      'El niño no presenta problemas respiratorios ni síntomas de asma.';

  @override
  String get symptomBDescription =>
      'El niño presenta síntomas leves u ocasionales.';

  @override
  String get symptomCDescription =>
      'El niño presenta síntomas la mayoría de los días o síntomas más graves.';

  @override
  String get aboutOverviewBody =>
      'La app Asesor de Actividad para el Asma guía a los usuarios preguntando sobre los síntomas actuales del niño, consultando los niveles de contaminación del aire en tiempo real y calculando niveles de actividad recomendados según reglas de salud establecidas. Esta funcionalidad ayuda a reducir el riesgo y brinda tranquilidad a las familias y a las organizaciones que atienden a jóvenes.';

  @override
  String get aboutObjectiveTitle => 'Objetivo';

  @override
  String get aboutObjectiveBody =>
      'La contaminación del aire-especialmente por humo de incendios forestales, tráfico y emisiones industriales-puede desencadenar síntomas graves de asma. Los cuidadores y educadores a menudo no tienen una forma simple y confiable de evaluar cuándo es seguro realizar actividades al aire libre. Esta app cubre esa necesidad al ofrecer orientación oportuna y basada en evidencia para ayudar a prevenir crisis de asma evitables.\n\nEl asma es una enfermedad crónica que afecta a muchos niños. Aunque no tiene cura, puede manejarse con la información correcta en el momento adecuado. Esta app está diseñada para ser ampliamente accesible y apoyar a escuelas, familias y cuidadores para mantener a los niños seguros y activos.';

  @override
  String get aboutHowItWorksTitle => 'Cómo funciona';

  @override
  String get aboutHowItWorksBody =>
      'La app digitaliza una regla deslizante tradicional del asma en una aplicación móvil y web. Integra datos en tiempo real del Índice de Calidad del Aire (AQI) con el estado respiratorio del niño y pautas estandarizadas de actividad física.\n\nAl combinar estas entradas, la app ofrece recomendaciones claras sobre niveles de actividad apropiados según las condiciones actuales de calidad del aire.';

  @override
  String get aboutInputsTitle => 'Entradas';

  @override
  String get aboutInputsBody =>
      '• Estado de salud respiratoria del niño (nivel de síntomas)\n• Índice de Calidad del Aire (AQI)';

  @override
  String get aboutOutputTitle => 'Salida';

  @override
  String get aboutOutputBody =>
      '• Niveles de actividad recomendados (baja, moderada, vigorosa)';

  @override
  String get aboutAirQualityRisksTitle =>
      'Comprender la calidad del aire y los riesgos para la salud';

  @override
  String get aboutAirQualityRisksBody =>
      'La contaminación del aire ocurre cuando contaminantes como humo, gases de escape de vehículos, emisiones industriales y otras partículas en el aire se acumulan en la atmósfera. En ciertas condiciones climáticas-como poco movimiento del aire o estratificación atmosférica-estos contaminantes pueden quedar atrapados cerca del suelo en lugar de dispersarse en la atmósfera superior. Cuando esto sucede, los niveles de contaminación aumentan y pueden crear condiciones brumosas que reducen la visibilidad y degradan la calidad del aire. Estas condiciones pueden persistir hasta que cambien los patrones climáticos y el aire limpio pueda circular y dispersar los contaminantes.\n\nEl humo de incendios forestales puede viajar cientos de millas a sotavento. Las partículas más grandes, como la ceniza, suelen caer más cerca del incendio. Sin embargo, las partículas más pequeñas representan el mayor riesgo para la salud y pueden viajar más lejos. Estas diminutas partículas, conocidas como PM2.5 (aproximadamente 1/50 del tamaño de un grano de arena), pueden inhalarse profundamente hasta los sacos de aire de los pulmones, donde pueden causar inflamación.\n\nLa exposición a corto plazo al humo y otros contaminantes del aire puede irritar los ojos, la nariz y la garganta y puede provocar tos o dificultades para respirar. La exposición a largo plazo puede contribuir al daño pulmonar y aumentar el riesgo de problemas cardiovasculares. Las personas con afecciones pulmonares o respiratorias preexistentes son especialmente vulnerables, aunque la mala calidad del aire puede afectar a cualquier persona.';

  @override
  String get aboutResourcesTitle => 'Recursos';

  @override
  String get aboutResourceAirNow => 'AQI de AirNow (Boise)';

  @override
  String get aboutResourceBsuAirQuality =>
      'Recursos de Boise State sobre calidad del aire y humo';

  @override
  String get aboutContactTitle => 'Contáctanos';

  @override
  String get aboutContactBody =>
      'Para cualquier pregunta o más información, comunícate con el Instituto de Resiliencia de Boise State University.';

  @override
  String get aboutResourceBsuResilienceInstitute =>
      'Instituto de Resiliencia de Boise State';

  @override
  String get recommendationMissingLocationMessage =>
      'Usa \"Usar mi ubicación\" o ingresa un código ZIP o ciudad en la pantalla principal para ver la calidad del aire.';

  @override
  String get recommendationNoLocationProvided =>
      'No se proporcionó ubicación. Usa \"Usar mi ubicación\" o ingresa un ZIP o ciudad.';

  @override
  String get nextDayGuidanceButton =>
      'Ver guía de actividad para el día siguiente';

  @override
  String get nextDayGuidanceTitle => 'Guía de actividad para el día siguiente';

  @override
  String get nextDayGuidanceSubtitle =>
      'Recomendación para mañana basada en el pronóstico.';

  @override
  String get loadingNextDayForecast => 'Cargando pronóstico del día siguiente';

  @override
  String forecastAqiLabel(Object aqi, Object category) {
    return 'AQI pronosticado: $aqi ($category)';
  }

  @override
  String locationLabelValue(Object location) {
    return 'Ubicación: $location';
  }

  @override
  String get airQualityTitle => 'Calidad del aire';

  @override
  String get loadingAirQuality => 'Cargando calidad del aire';

  @override
  String get loadingAirQualityEllipsis => 'Cargando calidad del aire…';

  @override
  String get enterLocationForAqi =>
      'Ingresa una ubicación en inicio para ver el AQI';

  @override
  String aqiLabelValue(Object aqi, Object category) {
    return 'AQI: $aqi  •  $category';
  }

  @override
  String updatedRelative(Object relative) {
    return 'Actualizado $relative';
  }

  @override
  String lastKnownAqi(Object aqi, Object category) {
    return 'Último dato: AQI $aqi ($category)';
  }

  @override
  String get relativeJustNow => 'justo ahora';

  @override
  String relativeMinutesAgo(Object minutes) {
    return 'hace $minutes min';
  }

  @override
  String relativeHoursAgo(Object hours) {
    return 'hace $hours h';
  }

  @override
  String relativeDaysAgo(Object days) {
    return 'hace $days día(s)';
  }

  @override
  String activityLoading(Object label) {
    return '$label: cargando...';
  }

  @override
  String get activityRecommended => 'Recomendada';

  @override
  String get activityNotRecommended => 'No recomendada';

  @override
  String get recommendedActivityTitle => 'Actividad recomendada';

  @override
  String get recommendationPendingMessage =>
      'La recomendación aparecerá aquí cuando el AQI esté disponible.';

  @override
  String get lightActivity => 'Actividad ligera';

  @override
  String get mediumActivity => 'Actividad moderada';

  @override
  String get vigorousActivity => 'Actividad vigorosa';

  @override
  String get activityExamplesTitle => 'Ejemplos de actividad';

  @override
  String get exampleLight1 => 'Caminar lentamente en terreno plano';

  @override
  String get exampleLight2 => 'Sentarse en una silla, estar de pie';

  @override
  String get exampleLight3 => 'Usar la computadora';

  @override
  String get exampleLight4 => 'Escribir en papel o pizarra';

  @override
  String get exampleLight5 => 'Cocinar, comer, beber';

  @override
  String get exampleLight6 => 'Tocar instrumentos musicales';

  @override
  String get exampleLight7 => 'Llevar libros escolares';

  @override
  String get exampleModerate1 => 'Jugar bádminton';

  @override
  String get exampleModerate2 => 'Andar en patineta';

  @override
  String get exampleModerate3 => 'Baile aeróbico';

  @override
  String get exampleModerate4 => 'Tenis de mesa competitivo';

  @override
  String get exampleModerate5 => 'Softbol de lanzamiento lento';

  @override
  String get exampleModerate6 => 'Tirar al aro en baloncesto';

  @override
  String get exampleModerate7 => 'Carpintería al aire libre';

  @override
  String get exampleVigorous1 => 'Correr, trotar';

  @override
  String get exampleVigorous2 => 'Hacer saltos de tijera';

  @override
  String get exampleVigorous3 => 'Fútbol americano, fútbol, béisbol';

  @override
  String get exampleVigorous4 => 'Natación competitiva';

  @override
  String get exampleVigorous5 => 'Hockey sobre hielo, waterpolo';

  @override
  String get exampleVigorous6 => 'Ráquetbol, squash';

  @override
  String get explanationPending =>
      'La explicación aparecerá aquí después de obtener una recomendación.';

  @override
  String get explanationGreen =>
      'La calidad del aire es buena. La mayoría de las personas, incluso con síntomas, pueden realizar actividades al aire libre de forma segura.';

  @override
  String get explanationYellow =>
      'La calidad del aire es aceptable. Las personas sensibles pueden presentar síntomas leves, así que considera limitar el esfuerzo prolongado.';

  @override
  String get explanationOrange =>
      'La calidad del aire no es saludable para grupos sensibles. Los síntomas pueden empeorar, así que reduce la intensidad y duración de la actividad al aire libre.';

  @override
  String get explanationRed =>
      'La calidad del aire no es saludable. Se recomienda evitar actividades intensas al aire libre, especialmente si hay síntomas.';

  @override
  String get explanationPurple =>
      'La calidad del aire es muy no saludable. Deben evitarse las actividades al aire libre debido al alto riesgo de agravar los síntomas.';

  @override
  String get explanationUnknown => 'No se pudo determinar la recomendación';

  @override
  String get whyRecommendationTitle => 'Por qué esta recomendación';

  @override
  String get moreInformation => 'Más información';

  @override
  String get disclaimerText =>
      'Esta app es solo una herramienta de orientación y no sustituye el consejo médico profesional. No diagnostica asma ni ninguna condición médica y no brinda orientación médica de emergencia.';
}
