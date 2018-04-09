# !/bin/bash
#oc new-project helloworld-msa
#cd hola
#mvn package fabric8:deploy
#cd ..
#cd aloha
#mvn package fabric8:deploy
#cd ..
#cd ola
#mvn package fabric8:deploy
#cd ..
cd bonjour
#oc new-build --binary --name=bonjour -l app=bonjour
npm install; oc start-build bonjour --from-dir=. --follow
oc new-app bonjour -l app=bonjour
oc expose service bonjour
oc set probe dc/bonjour --readiness --get-url=http://:8080/api/health
cd api-gateway
mvn package fabric8:deploy
cd ..
cd frontend
oc new-build --binary --name=frontend -l app=frontend
npm install; oc start-build frontend --from-dir=. --follow
oc new-app frontend -l app=frontend
oc expose service frontend
oc env dc/frontend OS_SUBDOMAIN=$($OPENSHIFT-SUBDOMAIN)
oc set probe dc/frontend --readiness --get-url=http://:8080/
cd ..
oc process -f ./kubeflix/kubeflix-1.0.17-kubernetes.yml | oc create -f -
oc expose service hystrix-dashboard --port=8080
oc policy add-role-to-user admin system:serviceaccount:helloworld-msa:turbine

oc env dc/frontend ENABLE_HYSTRIX=true

oc process -f ./jaeager/jaeger-all-in-one-template.yml | oc create -f -
oc env dc -l app JAEGER_SERVER_HOSTNAME=jaeger-all-in-one  # redeploy all services with tracing
oc env dc/frontend ENABLE_JAEGER=true
