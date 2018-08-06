
# mytomcatimage
##FROM rhel7/rhel
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
MAINTAINER Shrish Srivastava <shsrivas@redhat.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Tomcat image for S2I demo" \
      io.k8s.display-name="mytomcat 7.0.78" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,mytomcat" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i"

# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/
COPY apache-tomcat-7.0.78.zip /tmp 
RUN unzip /tmp/apache-tomcat-7.0.78.zip -d  /opt
RUN yum install -y java && yum clean all -y
RUN yum install -y maven.noarch && yum clean all -y


# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./.s2i/bin/ /usr/local/s2i
##Reuired so that it can be run on openshift without anyuid privilege.
RUN chgrp -R 0 /opt/apache-tomcat-7.0.78 && chmod -R g+rwX /opt/apache-tomcat-7.0.78
# chmod -R g=u directory 
# The g=u argument from the chmod command makes the group permissions equals to the owner user permissions, which by default are read and write. You can use the g+rwX argument with the same results.
# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
# RUN chown -R 1001:1001 /opt/app-root
 RUN chown -R 1001 /opt/apache-tomcat-7.0.78 && chmod -R +rwx /opt/apache-tomcat-7.0.78/ 

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["/usr/local/s2i/usage"]

