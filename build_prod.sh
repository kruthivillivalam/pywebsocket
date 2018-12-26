APP_NAME="basic_bokeh"
APP_VER="v1.0.0"

sudo docker build --no-cache=true --tag royhillanalytics.azurecr.io/${APP_NAME}:${APP_VER} .

echo "Build Complete"
echo "Run it with: "
echo "sudo docker run -it --rm --name flask -p 80:80 -p 2222:2222 royhillanalytics.azurecr.io/${APP_NAME}:${APP_VER}"
echo ""
echo -n If everything looks OK, press enter to push the image to the repository
read
sudo docker push royhillanalytics.azurecr.io/${APP_NAME}:${APP_VER}
