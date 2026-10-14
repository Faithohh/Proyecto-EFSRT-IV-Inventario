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
        Schema::create('PERSONAL', function (Blueprint $table) {
            $table->integer('idPersonal')->autoIncrement()->primary();
            $table->string('documentoIdentidad', 15)->nullable();
            $table->string('nombres', 50)->nullable();
            $table->string('apellidoPaterno', 50)->nullable();
            $table->string('apellidoMaterno', 50)->nullable();
            $table->string('cargo', 100)->nullable();
            $table->string('correoElectronico', 100)->nullable();
            $table->string('telefonoCompleto', 20)->nullable();
            $table->boolean('st_registro')->default(1);
            $table->string('idUsuarioCrea', 15)->nullable();
            $table->dateTime('fechaCreacion')->nullable();
            $table->string('pcTerminalCrea', 100)->nullable();
            $table->string('idUsuarioModifica', 15)->nullable();
            $table->dateTime('fechaModificacion')->nullable();
            $table->string('pcTerminalModifica', 100)->nullable();
            $table->unique('documentoIdentidad', 'uk_personal_dni');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('personals');
    }
};
