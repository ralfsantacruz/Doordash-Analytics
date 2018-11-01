import csv

mylist = ["Customer placed order datetime","Placed order with restaurant datetime","Driver at restaurant datetime", "Delivered to consumer datetime","Driver ID","Restaurant ID","Consumer ID","Is New","Delivery Region","Is ASAP","Order total","Amount of discount","Amount of tip","Refunded amount"]
# for x in mylist:
#     x.replace(" ", "_")

newlist = [x.replace(" ", "_") for x in mylist]

with open("columns.csv", "w",newline='') as f:
    writer = csv.writer(f)
    writer.writerow(newlist)
