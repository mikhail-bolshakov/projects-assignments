reader = csv.reader(open_file)
    rows=[row for idx, row in enumerate(reader) if idx in (range(9945,9960))]
    for i in rows:
        print(i)