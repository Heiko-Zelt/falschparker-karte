{
  gsub(/\r/, "", $4);
  if($4 != "-1") {
    printf("%s;%s;%s\n", $2, $3, $4);
  }
}
