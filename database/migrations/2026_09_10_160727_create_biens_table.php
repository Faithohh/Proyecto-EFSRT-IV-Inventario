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
        Schema::create('BIEN', function (Blueprint $table) {
            $table->integer('idBien')->autoIncrement()->primary();
            $table->integer('idSala')->nullable();
            $table->integer('idGrupo')->nullable();
            $table->string('cbi', 10)->nullable();
            $table->integer('idTipo')->nullable();
            $table->string('descripcion', 100)->nullable();
            $table->integer('idMarca')->nullable();
            $table->integer('idModelo')->nullable();
            $table->string('serieMedida', 100)->nullable();
            $table->integer('idEstado')->nullable();
            $table->string('otrasEspecificaciones', 100)->nullable();
            $table->boolean('st_registro')->default(1);
            $table->string('idUsuarioCrea', 15)->nullable();
            $table->dateTime('fechaCreacion')->nullable();
            $table->string('pcTerminalCrea', 100)->nullable();
            $table->string('idUsuarioModifica', 15)->nullable();
            $table->dateTime('fechaModificacion')->nullable();
            $table->string('pcTerminalModifica', 100)->nullable();
            $table->unique('cbi', 'uk_bien_cbi');
            $table->unique('serieMedida', 'uk_bien_serie');
            $table->foreign('idSala')->references('idSala')->on('SALA');
            $table->foreign('idGrupo')->references('idGrupo')->on('GRUPO');
            $table->foreign('idTipo')->references('idTipo')->on('TIPO');
            $table->foreign('idMarca')->references('idMarca')->on('MARCA');
            $table->foreign('idModelo')->references('idModelo')->on('MODELO');
            $table->foreign('idEstado')->references('idEstado')->on('ESTADO');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('biens');
    }
};
