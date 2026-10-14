<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('INVENTARIO_DETALLE', function (Blueprint $table) {
            $table->integer('idInventarioDetalle')->autoIncrement()->primary();
            
            $table->unsignedInteger('idInventario');
            $table->unsignedInteger('idBien')->nullable();
            
            $table->integer('idGrupo')->nullable();
            $table->string('nombreGrupo', 100)->nullable();
            $table->string('nroDRELM', 50)->nullable();
            $table->string('cbi', 10)->nullable();
            $table->integer('idTipo')->nullable();
            $table->string('nombreTipo', 100)->nullable();
            $table->string('descripcion', 100)->nullable();
            $table->integer('idMarca')->nullable();
            $table->string('nombreMarca', 100)->nullable();
            $table->integer('idModelo')->nullable();
            $table->string('nombreModelo', 100)->nullable();
            $table->string('serieMedida', 100)->nullable();
            $table->integer('idEstado')->nullable();
            $table->string('nombreEstado', 50)->nullable();
            $table->string('otrasEspecificaciones', 100)->nullable();
            $table->boolean('st_registro')->default(1);
            $table->foreign('idInventario')->references('idInventario')->on('INVENTARIO')->onDelete('cascade');
            $table->foreign('idBien')->references('idBien')->on('BIEN')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('INVENTARIO_DETALLE');
    }
};