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
        Schema::create('toma_inventarios', function (Blueprint $table) {
            $table->id();

            $table->integer('anio');
            $table->integer('numero');

            $table->integer('sala_id');
            $table->integer('coordinador_id');
            $table->integer('asistente1_id');
            $table->integer('asistente2_id')->nullable();

            $table->date('fecha_entrega')->nullable();
            $table->string('observacion', 255)->nullable();
            $table->string('estado', 50);

            $table->timestamps();

            $table->foreign('sala_id')
                ->references('idSala')
                ->on('SALA');

            $table->foreign('coordinador_id')
                ->references('idPersonal')
                ->on('PERSONAL');

            $table->foreign('asistente1_id')
                ->references('idPersonal')
                ->on('PERSONAL');

            $table->foreign('asistente2_id')
                ->references('idPersonal')
                ->on('PERSONAL');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('toma_inventarios');
    }
};