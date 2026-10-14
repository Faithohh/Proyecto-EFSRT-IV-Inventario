<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Bien extends Model
{
    protected $table = 'bien';
    protected $primaryKey = 'idBien';
    public $timestamps = false;

    protected $fillable = [
        'idSala',
        'idGrupo',
        'cbi',
        'idTipo',
        'descripcion',
        'idMarca',
        'idModelo',
        'serieMedida',
        'idEstado',
        'otrasEspecificaciones',
        'st_registro',
        'idUsuarioCrea',
        'fechaCreacion',
        'pcTerminalCrea',
        'idUsuarioModifica',
        'fechaModificacion',
        'pcTerminalModifica',
    ];
}