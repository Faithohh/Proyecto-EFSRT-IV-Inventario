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
        Schema::create('INVENTARIO', function (Blueprint $table) {
            $table->integer('idInventario')->autoIncrement()->primary();
            $table->integer('idProgramaEstudio')->nullable();
            $table->string('serie', 10)->nullable();
            $table->integer('numero')->nullable();
            $table->integer('idSala')->nullable();
            $table->string('nombreSala', 100)->nullable();
            $table->integer('idCoordinadorArea')->nullable();
            $table->string('nombreCoordinadorArea', 150)->nullable();
            $table->integer('idAsistenteAreaT1')->nullable();
            $table->string('nombreAsistenteAreaT1', 150)->nullable();
            $table->integer('idAsistenteAreaT2')->nullable();
            $table->string('nombreAsistenteAreaT2', 150)->nullable();
            $table->dateTime('fechaEntrega')->nullable();
            $table->string('observacion', 250)->nullable();
            $table->string('st_inventario', 2)->nullable();
            $table->boolean('st_registro')->default(1);
            $table->string('idUsuarioCrea', 15)->nullable();
            $table->dateTime('fechaCreacion')->nullable();
            $table->string('pcTerminalCrea', 100)->nullable();
            $table->foreign('idProgramaEstudio')->references('idProgramaEstudio')->on('PROGRAMAESTUDIO');
            $table->foreign('idSala')->references('idSala')->on('SALA');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('inventarios');
    }
};
