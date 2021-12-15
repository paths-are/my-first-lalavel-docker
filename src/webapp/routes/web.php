<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    $value = 'Snome';
    $arr = ['Snome1', 'Snome2', 'Snome3'];
  
    return view('sample', compact('value', 'arr'));
    // return view('welcome');
});
