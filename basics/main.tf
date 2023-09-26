output "hello1" {
  value = "Hello, ${var.username}. Age: ${var.age}. Languages: ${join(", ",var.language)}"
}

output "hello2" {
  value = upper(join(", ", var.language))
}

output "hello3" {
  value = "User1: Person1 = ${lookup(var.member,"Person1" )}"
}

output "hello4" {
  value = "User1: ${var.username} = ${lookup(var.member,var.username )}"
}