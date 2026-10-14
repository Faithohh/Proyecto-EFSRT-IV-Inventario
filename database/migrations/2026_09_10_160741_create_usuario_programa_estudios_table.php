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
        Schema::create('USUARIO_PROGRAMAESTUDIO', function (Blueprint $table) {
            $table->string('idUsuario', 15);
            $table->integer('idProgramaEstudio');
            $table->boolean('st_registro')->default(1);

            // LLAVE PRIMARIA COMPUESTA (La combinación de ambas columnas es la PK)
            $table->primary(['idUsuario', 'idProgramaEstudio']);

            // Llaves Foráneas
            $table->foreign('idUsuario')->references('idUsuario')->on('USUARIO');
            $table->foreign('idProgramaEstudio')->references('idProgramaEstudio')->on('PROGRAMAESTUDIO');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('usuario_programa_estudios');
    }
};
