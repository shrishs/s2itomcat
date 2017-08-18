Demonstrating builder image creation and SCC 
---------------------------------------------
Step1:
oc new-project tomcatweb

Step2:
Create the s2i directory structure
../s2i create mytomcatimage mytomcat

Step3:
Copy all the corresponding file from https://github.com/shrishs/s2itomcat

Step3:
Make sure for the first demo, following line is commented in DOCKERFILE
##RUN chgrp -R 0 /opt/apache-tomcat-7.0.78 && chmod -R g+rwX /opt/apache-tomcat-7.0.78

Step4:
Create the builder image.
docker build -t mytomcatimage .

Step5:(optional)
Following are the steps to test the builder image using s2i ,which is not required for Demo

../../s2i build https://github.com/shrishs/openshift-quickstarts.git --context-dir=tomcat-websocket-chat mytomcatimage:latest mytomcatappimage
docker run -p 8080:8080 mytomcatappimage:latest
docker run -d -p 8080:8080 mytomcatappimage:latest
docker exec -it <contid> bash

Step6:

Pushing the newly created builder image into internal registry
--Login to the registry
docker login -u admin11 -e eeeee -p DVzEck0ibaI16OL8Iz_L-BrU1ruONIwmHwID-UmTxt4 docker-registry-default.app.sandbox.com
--Tag it according to internal registry naming convention
docker tag mytomcatimage docker-registry-default.app.sandbox.com/tomcatweb/mytomcatbuilder
--Push the newly tagged image to internal registry
docker push docker-registry-default.app.sandbox.com/tomcatweb/mytomcatbuilder

Step7:Create an application using the pushed builder image.
--For the above builder image ,an imagestream(mytomcatbuilder) would be created in tomcatweb project.
--Create a new app with the above builder image.
oc new-app mytomcatbuilder~https://github.com/shrishs/openshift-quickstarts.git --context-dir=tomcat-websocket-chat --name=frombuilderimage
--Check the logs of the created pod
      ----
      SEVERE: Failed to open access log file [/opt/apache-tomcat-7.0.78/logs/localhost_access_log.2017-05-29.txt]
      java.io.FileNotFoundException: /opt/apache-tomcat-7.0.78/logs/localhost_access_log.2017-05-29.txt (Permission denied)
      at java.io.FileOutputStream.open0(Native Method)
      ----

Step8:
As above docker image is running with user 1001 in docker but openshift assign its userid from the range of its own pool and all the users belongs to gid 0.We need to change the SCC to anyuid.
--Add default user to anyuid
oadm policy add-scc-to-user anyuid -z default
--Recreate the pods
  pods should be working ,Show the application after creatin the Pod. 
  Show the running uid in console

Step9:
--Remove default user from anyuid
oadm policy remove-scc-from-user anyuid -z default
     and recreate the pod ,let if fail

Step10:Provide group id 0 to all the required privilege 
--Uncomment the group permission line and repeat the process from docker build(Step4)
--Also mention how a build is trigger on the change(push) of builder image
--This time app will work without mentioning any specific scc. 

