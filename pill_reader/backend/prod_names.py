import csv
import os

file = open('products.csv')
reader = csv.reader(file)
out_file = open("drug_names.txt", 'w')
next(reader, None)
count = 0
if __name__ == "__main__":
    for row in reader:
        count = count + 1
        drug_name = row[5]
        print(drug_name)
        out_file.write(drug_name)
        out_file.write('\n')

    print(count)