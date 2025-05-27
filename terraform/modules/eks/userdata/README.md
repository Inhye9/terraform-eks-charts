## templatefile 함수
# templatefile 함수는 템플릿 파일 내의 플레이스홀더 ${}를 실제 값으로 대체하여 구성 파일을 동적으로 생성하는 용도임
# 해당 함수에 제공하는 스크립트 파일 확장자는 제한없이 사용가능하지만 편의상 .sh 사용함

## templatefile 내 동적 처리 및 이스케이프
# 테라폼 templatefile을 통해 처리 시 ${}를 통해 필요한 변수를 동적으로 넣어줄 수 있다
# 스크립트에 이미 존재했던 ${}은 노드 부팅 간 userdata 실행 시 동적으로 들어가야할 값이므로, templatefile을 통해 처리되지 않도록 이스케이프 처리가 필요하다
# 처리 방법은 $를 하나 더 붙여주면됨 ex) $${instance_id}

## bootstrap.sh 실행 시 특이사항
# 클러스터 조인을 위한 eksbootstrap.sh 파일은 EKS 최적화 AMI 안에 저장되어있으며, cloud-init을 통해서 노드 시작 시 실행된다
# 이 때 정의해야하는 값 중 apiserver-endpoint, --b64-cluster-ca 및 --dns-cluster-ip 인수는 선택사항으로 언급되어있으며, 실제로 없더라도 클러스터 조인이 가능했다
# 이 값이 없으면 노드 시작 시 bootstrap.sh 스크립트가 describeCluster를 호출하게 되는데 호출 자체가 컨트롤플레인 내 apiserver에 부하를 주므로,
# 노드를 자주 확장하고 축소하는 프라이빗 클러스터에서는 이 값을 지정하는 것을 권장함
# https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
# https://github.com/awslabs/amazon-eks-ami/blob/main/templates/al2/runtime/bootstrap.sh

## bootstrap.sh 스크립트에 설정할 수 있는 인자
# https://github.com/awslabs/amazon-eks-ami/blob/main/templates/al2/runtime/bootstrap.sh