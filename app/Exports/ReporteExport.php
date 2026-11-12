<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithEvents;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Events\AfterSheet;

class ReporteExport implements FromArray, WithEvents, WithColumnWidths, WithTitle
{
    protected $informe;
    protected $filasGrupo = [];
    protected $filaEncabezado = 10;
    protected $filaPie = 0;

    public function __construct($informe)
    {
        $this->informe = $informe;
    }

    public function array(): array
    {
        $inventario = $this->informe['inventario'];
        $bienes = $this->informe['bienes'];

        $filas = [
            ['INSTITUTO DE EDUCACIÓN SUPERIOR TECNOLÓGICO PÚBLICO', '', '', '', '', '', '', '', '', ''],
            ['JULIO CÉSAR TELLO', '', '', '', '', '', '', '', '', ''],
            ['CARGO DE ASIGNACIÓN DE BIENES EN USO', '', '', '', '', '', '', '', '', ''],
            ['', '', '', '', '', '', '', '', '', ''],
            ['INVENTARIO', $inventario->INVENTARIO ?? '-', '', '', 'SALA', $inventario->SALA ?? '-', '', '', '', ''],
            ['COORDINADOR', $inventario->COORDINADOR ?? '-', '', '', 'ASISTENTE T1', $inventario->ASISTENTE_T1 ?? '-', '', '', '', ''],
            ['ASISTENTE T2', $inventario->ASISTENTE_T2 ?? '-', '', '', 'FECHA ENTREGA', $inventario->FECHA_ENTREGA ?? '-', '', '', '', ''],
            ['ESTADO', $inventario->ESTADO ?? '-', '', '', 'OBSERVACIÓN', $inventario->OBSERVACION ?? '-', '', '', '', ''],
            ['', '', '', '', '', '', '', '', '', ''],
            [
                'N°',
                'GRUPO',
                'INV. DRELM',
                'CBI',
                'DESCRIPCIÓN DEL BIEN',
                'MARCA',
                'MODELO',
                'SERIE / MEDIDA',
                'ESTADO',
                'OTRAS ESPECIFICACIONES'
            ]
        ];

        $numero = 0;
        $grupoActual = null;

        foreach ($bienes as $bien) {
            $grupo = $bien->GRUPO ?? 'SIN GRUPO';

            if ($grupo !== $grupoActual) {
                $filaGrupo = array_fill(0, 10, '');
                $filaGrupo[1] = 'GRUPO: ' . $grupo;

                $filas[] = $filaGrupo;
                $this->filasGrupo[] = count($filas);

                $grupoActual = $grupo;
            }

            $numero++;

            $filas[] = [
                $numero,
                $bien->GRUPO ?? '-',
                $bien->INV_DRELM ?? '-',
                $bien->CBI ?? '-',
                $bien->DESCRIPCION ?? '-',
                $bien->MARCA ?? '-',
                $bien->MODELO ?? '-',
                $bien->SERIE_MEDIDA ?? '-',
                $bien->ESTADO ?? '-',
                $bien->OTRAS_ESPECIFICACIONES ?? '-'
            ];
        }

        $filas[] = ['ESTADOS: 1 = NUEVO | 2 = BUENO | 3 = REGULAR | 4 = MALO', '', '', '', '', '', '', '', '', ''];

        $this->filaPie = count($filas);

        return $filas;
    }

    public function title(): string
    {
        return 'Informe de Inventario';
    }

    public function columnWidths(): array
    {
        return [
            'A' => 7,
            'B' => 18,
            'C' => 15,
            'D' => 14,
            'E' => 30,
            'F' => 16,
            'G' => 18,
            'H' => 20,
            'I' => 13,
            'J' => 35
        ];
    }

    public function registerEvents(): array
    {
        return [
            AfterSheet::class => function (AfterSheet $event) {
                $hoja = $event->sheet->getDelegate();
                $ultimaFila = $this->filaPie;

                $hoja->mergeCells('A1:J1');
                $hoja->mergeCells('A2:J2');
                $hoja->mergeCells('A3:J3');

                for ($fila = 5; $fila <= 8; $fila++) {
                    $hoja->mergeCells("B{$fila}:D{$fila}");
                    $hoja->mergeCells("F{$fila}:J{$fila}");
                }

                $hoja->mergeCells("A{$ultimaFila}:J{$ultimaFila}");

                $hoja->getStyle("A1:J{$ultimaFila}")->getFont()->setName('Arial');
                $hoja->getStyle("A1:J{$ultimaFila}")->getAlignment()
                    ->setVertical(\PhpOffice\PhpSpreadsheet\Style\Alignment::VERTICAL_CENTER);

                $hoja->getStyle('A1:J1')->applyFromArray([
                    'font' => [
                        'bold' => true,
                        'size' => 10
                    ],
                    'alignment' => [
                        'horizontal' => \PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER
                    ]
                ]);

                $hoja->getStyle('A2:J2')->applyFromArray([
                    'font' => [
                        'bold' => true,
                        'size' => 14
                    ],
                    'alignment' => [
                        'horizontal' => \PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER
                    ]
                ]);

                $hoja->getStyle('A3:J3')->applyFromArray([
                    'font' => [
                        'bold' => true,
                        'size' => 13,
                        'color' => ['rgb' => 'FFFFFF']
                    ],
                    'fill' => [
                        'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                        'startColor' => ['rgb' => '1F3B64']
                    ],
                    'alignment' => [
                        'horizontal' => \PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER
                    ]
                ]);

                $hoja->getStyle('A5:J8')->applyFromArray([
                    'font' => [
                        'size' => 10
                    ],
                    'borders' => [
                        'allBorders' => [
                            'borderStyle' => \PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN,
                            'color' => ['rgb' => 'B7C9D6']
                        ]
                    ]
                ]);

                $hoja->getStyle('A5:A8')->getFont()->setBold(true);
                $hoja->getStyle('E5:E8')->getFont()->setBold(true);

                $hoja->getStyle('A' . $this->filaEncabezado . ':J' . $this->filaEncabezado)->applyFromArray([
                    'font' => [
                        'bold' => true,
                        'color' => ['rgb' => 'FFFFFF'],
                        'size' => 10
                    ],
                    'fill' => [
                        'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                        'startColor' => ['rgb' => '1F5FA8']
                    ],
                    'alignment' => [
                        'horizontal' => \PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER,
                        'vertical' => \PhpOffice\PhpSpreadsheet\Style\Alignment::VERTICAL_CENTER,
                        'wrapText' => true
                    ],
                    'borders' => [
                        'allBorders' => [
                            'borderStyle' => \PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN,
                            'color' => ['rgb' => 'FFFFFF']
                        ]
                    ]
                ]);

                $hoja->getRowDimension($this->filaEncabezado)->setRowHeight(35);

                if ($ultimaFila > $this->filaEncabezado + 1) {
                    $hoja->getStyle('A' . ($this->filaEncabezado + 1) . ':J' . ($ultimaFila - 1))->applyFromArray([
                        'font' => [
                            'size' => 9
                        ],
                        'alignment' => [
                            'vertical' => \PhpOffice\PhpSpreadsheet\Style\Alignment::VERTICAL_CENTER,
                            'wrapText' => true
                        ],
                        'borders' => [
                            'allBorders' => [
                                'borderStyle' => \PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN,
                                'color' => ['rgb' => 'B7C9D6']
                            ]
                        ]
                    ]);
                }

                foreach ($this->filasGrupo as $fila) {
                    $hoja->mergeCells("B{$fila}:J{$fila}");

                    $hoja->getStyle("A{$fila}:J{$fila}")->applyFromArray([
                        'font' => [
                            'bold' => true,
                            'color' => ['rgb' => '1F3B64'],
                            'size' => 10
                        ],
                        'fill' => [
                            'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                            'startColor' => ['rgb' => 'DCE6F1']
                        ],
                        'alignment' => [
                            'vertical' => \PhpOffice\PhpSpreadsheet\Style\Alignment::VERTICAL_CENTER
                        ]
                    ]);

                    $hoja->getRowDimension($fila)->setRowHeight(22);
                }

                $hoja->getStyle("A{$ultimaFila}:J{$ultimaFila}")->applyFromArray([
                    'font' => [
                        'bold' => true,
                        'size' => 10,
                        'color' => ['rgb' => 'FFFFFF']
                    ],
                    'fill' => [
                        'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                        'startColor' => ['rgb' => '1F3B64']
                    ],
                    'alignment' => [
                        'horizontal' => \PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_LEFT
                    ]
                ]);

                $hoja->freezePane('A11');

                $hoja->getPageSetup()
                    ->setOrientation(\PhpOffice\PhpSpreadsheet\Worksheet\PageSetup::ORIENTATION_LANDSCAPE);

                $hoja->getPageSetup()->setFitToWidth(1);
                $hoja->getPageSetup()->setFitToHeight(0);
                $hoja->getPageSetup()->setPaperSize(
                    \PhpOffice\PhpSpreadsheet\Worksheet\PageSetup::PAPERSIZE_A4
                );

                $hoja->getPageMargins()->setTop(0.4);
                $hoja->getPageMargins()->setBottom(0.4);
                $hoja->getPageMargins()->setLeft(0.3);
                $hoja->getPageMargins()->setRight(0.3);

                $hoja->getPageSetup()->setPrintArea("A1:J{$ultimaFila}");
            }
        ];
    }
}
