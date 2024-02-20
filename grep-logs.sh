#Check for PHP Fatal or Syntax Errors
if grep -qE "PHP (Fatal|Parse) error" ~/logs/error.log; then

    #Display Errors only if found
    echo "Fatal/Syntax Error Detected"
    echo
    grep -E "PHP (Fatal|Parse) error" ~/logs/error.log
    echo
fi
