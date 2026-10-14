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
        Schema::create('PROGRAMAESTUDIO', function (Blueprint $table) {
            $table->integer('idProgramaEstudio')->autoIncrement()->primary();
            $table->integer('idInstitucion')->nullable();
            $table->string('nombre', 100)->nullable();
            $table->integer('idCoordinadorArea')->nullable();
            $table->integer('idAsistenteAreaT1')->nullable();
            $table->integer('idAsistenteAreaT2')->nullable();
            $table->string('observacion', 100)->nullable();
            $table->boolean('st_programaEstudio')->default(1);
            $table->boolean('st_registro')->default(1);
            $table->string('idUsuarioCrea', 15)->nullable();
            $table->dateTime('fechaCreacion')->nullable();
            $table->string('pcTerminalCrea', 100)->nullable();
            $table->string('idUsuarioModifica', 15)->nullable();
            $table->dateTime('fechaModificacion')->nullable();
            $table->string('pcTerminalModifica', 100)->nullable();
            $table->foreign('idInstitucion')->references('idInstitucion')->on('INSTITUCION');
            $table->foreign('idCoordinadorArea')->references('idPersonal')->on('PERSONAL');
            $table->foreign('idAsistenteAreaT1')->references('idPersonal')->on('PERSONAL');
            $table->foreign('idAsistenteAreaT2')->references('idPersonal')->on('PERSONAL');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('programa_estudios');
    }
};
