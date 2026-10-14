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
        Schema::create('GRUPO', function (Blueprint $table) {
            $table->integer('idGrupo')->autoIncrement()->primary();
            $table->string('nombre', 100)->nullable();
            $table->string('nroDRELM', 50)->nullable();
            $table->boolean('st_registro')->default(1);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('GRUPO');
    }
};
