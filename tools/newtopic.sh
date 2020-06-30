#!/usr/bin/env bash
echo 'Choose the target guide:'
PS3='Please select the target guide: '
options=("administration-guide" "contributor-guide" "end-user-guide" "extensions" "installation-guide" "overview")
select guide in "${options[@]}"
do
    case $guide in
        "administration-guide")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "contributor-guide")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "end-user-guide")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "extensions")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "installation-guide")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "overview")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

cd "src/main/pages/che-7/$guide" || exit

echo 'Choose the topic nature:'

PS3='Please select the topic nature: '
options=("assembly" "concept" "procedure" "reference")
select nature in "${options[@]}"
do
    case $nature in
        "assembly")
            echo "you chose choice $REPLY which is $nature"
            break
            ;;
        "concept")
            echo "you chose choice $REPLY which is $nature"
            break
            ;;
        "procedure")
            echo "you chose choice $REPLY which is $nature"
            break
            ;;
        "reference")
            echo "you chose choice $REPLY which is $nature"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

echo 'Enter the title for the new topic';
read -r title;
newdoc --no-comments "--$nature" "${title}"