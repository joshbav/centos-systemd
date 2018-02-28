docker build -t joshbav/centos-systemd:latest .
echo
echo
echo
echo Pushing newly built image to dockerhub
echo
docker push joshbav/centos-systemd:latest
echo
echo
echo Uploading all files to github.com/joshbav/centos-systemd
echo
# ALl files to automatically be added
git add .
git config user.name “joshbav”
git commit -m "scripted commit"
git push -u origin master










