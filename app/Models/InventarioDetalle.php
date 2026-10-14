<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InventarioDetalle extends Model
{
    protected $table = 'inventario_detalle';
    
    protected $primaryKey = 'idInventarioDetalle';
    
    public $timestamps = false;
}
