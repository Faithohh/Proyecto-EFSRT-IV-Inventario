<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Informe de Inventario</title>

    <style>
        @page {
            margin: 25px;
        }

        body {
            font-family: Arial, sans-serif;
            font-size: 9px;
            color: #222;
        }

        .titulo {
            text-align: center;
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .subtitulo {
            text-align: center;
            font-size: 11px;
            margin-bottom: 20px;
        }

        .seccion {
            font-size: 11px;
            font-weight: bold;
            margin-top: 15px;
            margin-bottom: 8px;
            background-color: #e5e5e5;
            padding: 6px;
        }

        .datos {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 10px;
        }

        .datos td {
            border: 1px solid #999;
            padding: 6px;
        }

        .datos td:first-child {
            font-weight: bold;
            width: 20%;
            background-color: #f2f2f2;
        }

        .tabla {
            width: 100%;
            border-collapse: collapse;
            margin-top: 8px;
            font-size: 8px;
        }

        .tabla th {
            background-color: #26374a;
            color: white;
            padding: 6px 3px;
            border: 1px solid #555;
        }

        .tabla td {
            border: 1px solid #999;
            padding: 5px 3px;
            text-align: center;
        }

        .tabla td.descripcion {
            text-align: left;
        }

        .tabla tr.fila-grupo td {
            background-color: #dce6f1;
            color: #1f3b64;
            font-weight: bold;
            font-size: 9px;
            text-align: left;
            padding: 6px 6px;
        }

        .tabla tr {
            page-break-inside: avoid;
        }

        .observacion {
            border: 1px solid #999;
            padding: 8px;
            min-height: 25px;
        }

        .pie {
            margin-top: 25px;
            text-align: center;
            font-size: 8px;
            color: #666;
        }
    </style>
</head>
<body>

    <div class="titulo">
        INFORME DE INVENTARIO
    </div>

    <div class="subtitulo">
        INVENTARIO DE {{ $informe['inventario']->SALA }}
    </div>

    <div class="seccion">
        DATOS GENERALES
    </div>

    <table class="datos">
        <tr>
            <td>N° INVENTARIO</td>
            <td>{{ $informe['inventario']->INVENTARIO }}</td>
            <td>SALA</td>
            <td>{{ $informe['inventario']->SALA }}</td>
        </tr>
        <tr>
            <td>COORDINADOR</td>
            <td colspan="3">{{ $informe['inventario']->COORDINADOR }}</td>
        </tr>
        <tr>
            <td>ASISTENTE T1</td>
            <td>{{ $informe['inventario']->ASISTENTE_T1 }}</td>
            <td>ASISTENTE T2</td>
            <td>{{ $informe['inventario']->ASISTENTE_T2 }}</td>
        </tr>
        <tr>
            <td>FECHA DE ENTREGA</td>
            <td>{{ $informe['inventario']->FECHA_ENTREGA }}</td>
            <td>ESTADO</td>
            <td>{{ $informe['inventario']->ESTADO }}</td>
        </tr>
    </table>

    <div class="seccion">
        DETALLE DE BIENES INVENTARIADOS
    </div>

    <table class="tabla">
        <thead>
            <tr>
                <th>N°</th>
                <th>INV. DRELM</th>
                <th>CBI</th>
                <th>DESCRIPCIÓN</th>
                <th>MARCA</th>
                <th>MODELO</th>
                <th>SERIE / MEDIDA</th>
                <th>ESTADO</th>
                <th>OTRAS ESPECIFICACIONES</th>
            </tr>
        </thead>

        <tbody>
            @php
                $grupoActual = null;
                $numero = 0;
            @endphp
            @forelse ($informe['bienes'] as $bien)
                @php $grupo = $bien->GRUPO ?? 'SIN GRUPO'; @endphp

                @if ($grupo !== $grupoActual)
                    <tr class="fila-grupo">
                        <td colspan="9">GRUPO: {{ $grupo }}</td>
                    </tr>
                    @php $grupoActual = $grupo; @endphp
                @endif

                @php $numero++; @endphp
                <tr>
                    <td>{{ $numero }}</td>
                    <td>{{ $bien->INV_DRELM }}</td>
                    <td>{{ $bien->CBI }}</td>
                    <td class="descripcion">{{ $bien->DESCRIPCION }}</td>
                    <td>{{ $bien->MARCA }}</td>
                    <td>{{ $bien->MODELO }}</td>
                    <td>{{ $bien->SERIE_MEDIDA }}</td>
                    <td>{{ $bien->ESTADO }}</td>
                    <td>{{ $bien->OTRAS_ESPECIFICACIONES }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="9">No existen bienes registrados en este inventario.</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="seccion">
        OBSERVACIONES
    </div>

    <div class="observacion">
        {{ $informe['inventario']->OBSERVACION ?: 'Sin observaciones.' }}
    </div>

    <div class="pie">
        SISTEMA DE INVENTARIO - INFORME GENERADO AUTOMÁTICAMENTE
    </div>

</body>
</html>