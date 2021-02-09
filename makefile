include inc.Variables.mk

AWS_REGION := $(if $(AWS_REGION),$(AWS_REGION),eu-west-1)
AWS_ID := $(if $(AWS_ID),$(AWS_ID),203976053147)

docker-build:
	docker build -t $(NAME) .	
	
docker-run:
	docker run -d -p $(PORT):8080 $(NAME)

docker-test:
	curl -XPOST "http://localhost:$(PORT)/2015-03-31/functions/function/invocations" -d '{"payload":"hello world!"}'

make-docker:
	make docker-build
	make docker-run
ifeq ($(INVOKE),true)
	make docker-test
endif

ecr-create:
	aws ecr create-repository --repository-name $(NAME) --image-scanning-configuration scanOnPush=true

docker-tag:
	docker tag $(NAME):latest $(AWS_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(NAME):latest

docker-login: 
	aws ecr get-login-password | docker login --username AWS --password-stdin $(AWS_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

docker-push:
	docker push $(AWS_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(NAME)

lambda-create:
	aws lambda create-function --function-name $(NAME) --code ImageUri=$(AWS_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(NAME):latest --timeout 900 --package-type Image --role arn:aws:iam::$(AWS_ID):role/agron_data_collectors

lambda-update:
	aws lambda update-function-code --function-name $(NAME) --image-uri $(AWS_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(NAME):latest

lambda-invoke:
	aws lambda invoke --function-name $(NAME) --invocation-type RequestResponse response.json

make-deploy:
ifeq ($(ACTION),create)
		make ecr-create
endif

	make docker-tag
	make docker-login
	make docker-push

ifeq ($(ACTION),create)
		make lambda-create
else
		make lambda-update
endif

ifeq ($(INVOKE),true)
	make lambda-invoke
endif

update-tools:
	@curl -sL  https://raw.githubusercontent.com/akhtariali/agron_makefile/master/makefile > inc.Makefile.mk
	@read -p "Updated tools.  Do you want to commit and push? [y/N] " Y;\
	if [ "$$Y" == "y" ]; then git add inc.Makefile.mk && git commit -m "[min] Update tools" && git push; fi
	@$(DONE)