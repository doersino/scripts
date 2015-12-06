<?php

// Generate tripcodes containing words. The list of valid words is read from the
// file "/usr/share/dict/words" (modify this depending on your OS), but only
// words of length 5 to 7 are copied to the file "tripcode_words.txt", which is
// then used for tripcode generation. Output is of format "password : result".

function getWords() {
    $words = file_get_contents("/usr/share/dict/words");
    $words = explode("\n", $words);

    $usefulWords = array();
    foreach ($words as $word) {
        if (strlen($word) > 4 && strlen($word) < 8) {
            $usefulWords[] = $word;
        }
    }

    $file = fopen("tripcode_words.txt", "w+");
    fwrite($file, implode("\n", $usefulWords));
    fclose($file);
}

function tripcode($name) {
    if (ereg("(#|!)(.*)", $name, $matches)) {
        $cap  = $matches[2];
        $cap  = strtr($cap, "&amp;", "&");
        //$cap  = strtr($cap, ",", ",");
        $salt = substr($cap . "H.", 1, 2);
        $salt = ereg_replace("[^\.-z]", ".", $salt);
        $salt = strtr($salt, ":;<=>?@[\\]^_`", "ABCDEFGabcdef");
        return substr(crypt($cap, $salt), -10) . "";
    }
}

function contains($str, $arr) {
    foreach ($arr as $elem) {
        if (stripos($str, $elem) !== false) { // case-insensitive
            return true;
        }
    }
    return false;
}

getWords();

$usefulWords = file_get_contents("tripcode_words.txt");
$usefulWords = explode("\n", $usefulWords);

for ($i = 0; ; $i++) { // watch out - infinite loop
    $trip = substr(crypt($i), -15);
    $code = tripcode("#" . $trip);
    if (contains($code, $usefulWords)) {
        echo "$trip : $code \n";
    }
}

?>
