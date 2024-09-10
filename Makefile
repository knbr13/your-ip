FUNCTION_NAME=your-ip
ROLE_ARN=arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_LAMBDA_EXECUTION_ROLE

build:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o bootstrap main.go
	zip lambda-handler.zip bootstrap

update_lambda: build
	aws lambda update-function-code --function-name $(FUNCTION_NAME) --zip-file fileb://lambda-handler.zip

create_lambda: build
	aws lambda create-function \
		--function-name $(FUNCTION_NAME) \
		--runtime provided.al2023 \
		--handler main.handleRequest \
		--architectures arm64 \
		--role $(ROLE_ARN) \
		--zip-file fileb://lambda-handler.zip \
		--publish

	aws lambda add-permission \
		--function-name $(FUNCTION_NAME) \
		--statement-id AllowPublicAccess \
		--action lambda:InvokeFunctionUrl \
		--principal "*" \
		--function-url-auth-type NONE

	aws lambda create-function-url-config \
		--function-name $(FUNCTION_NAME) \
		--auth-type NONE
