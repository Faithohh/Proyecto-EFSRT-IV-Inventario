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
        Schema::create('SALA', function (Blueprint $table) {
            $table->integer('idSala')->autoIncrement()->primary();
            $table->integer('idProgramaEstudio')->nullable();
            $table->string('nombre', 100)->nullable();
            $table->string('piso', 10)->nullable();
            $table->string('pabellon', 50)->nullable();
            $table->string('observacion', 100)->nullable();
            $table->boolean('st_sala')->default(1);
            $table->boolean('st_registro')->default(1);
            $table->string('idUsuarioCrea', 15)->nullable();
            $table->dateTime('fechaCreacion')->nullable();
            $table->string('pcTerminalCrea', 100)->nullable();
            $table->string('idUsuarioModifica', 15)->nullable();
            $table->dateTime('fechaModificacion')->nullable();
            $table->string('pcTerminalModifica', 100)->nullable();
            $table->foreign('idProgramaEstudio')->references('idProgramaEstudio')->on('PROGRAMAESTUDIO');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('salas');
    }
};
