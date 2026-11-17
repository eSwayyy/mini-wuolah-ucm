$('#modalApunte').on('show.bs.modal', function (event) {

    const tarjeta = event.relatedTarget;
    const modal = $(this);

    const dato = (nombre) =>
        tarjeta.getAttribute('data-' + nombre);

    // Información principal
    modal.find('#detalleTitulo').text(dato('titulo'));
    modal.find('#detalleTipo').text(dato('tipo'));
    modal.find('#detalleFecha').text(dato('fecha'));

    // PDF
    modal.find('#detallePdf').attr('src', dato('pdf'));

    // Descarga
    modal.find('#detalleDescargar')
         .attr('href', dato('descarga'));

    // Autor
    modal.find('#detalleAutor')
         .text('@' + dato('autor'))
         .attr('href', dato('perfil'));

    // Carrera
    modal.find('#detalleCarrera')
         .text(dato('carrera'))
         .attr('href', dato('carrera-url'));

    // Asignatura
    modal.find('#detalleRamo')
         .text(dato('ramo'))
         .attr('href', dato('ramo-url'));

    // Estadísticas
    modal.find('#detalleLikes').text(dato('likes'));
    modal.find('#detalleComentarios').text(dato('comentarios'));
    modal.find('#detalleDescargas').text(dato('descargas'));

});

// Liberar el PDF al cerrar
$('#modalApunte').on('hidden.bs.modal', function () {
    $(this).find('#detallePdf').attr('src', 'about:blank');
});