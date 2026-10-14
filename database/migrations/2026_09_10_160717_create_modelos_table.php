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
        Schema::create('MODELO', function (Blueprint $table) {
            $table->integer('idModelo')->autoIncrement()->primary();
            $table->integer('idMarca')->nullable();
            $table->string('nombre', 100)->nullable();
            $table->boolean('st_registro')->default(1);
            $table->foreign('idMarca')->references('idMarca')->on('MARCA');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('modelos');
    }
};
