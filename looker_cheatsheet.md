# Looker table calculations

### First day of week

`offset(${marketing_attribution2.booking_first_date}, ${dow}-1)`
- ${dow} field see below

### DOW

`mod(diff_days(to_date("1970-01-05"),${marketing_attribution2.booking_first_date}),7)+1`

### Custom filter next 30 days
`${pipedrive_deals.partner_onboard_date} >= now() AND ${pipedrive_deals.partner_onboard_date}<=add_days(30, now())`

### Custom filter yesterday 

`matches_filter(${customer_service.full_date}, 'yesterday')`

### Custom filter YTD (to be verified)

`${conversion2_f.sale_date} >= trunc_years(now())`

### Days in month

`extract_days(add_days(-1, date(extract_years(add_months(1,now())), extract_months(add_months(1, now())), 1)))`

### Custom filter 30 days before last 30 days

`${conversion2_f.booking_first_date} > add_days(-61,now()) AND ${conversion2_f.booking_first_date} < add_days(-31,now())`


## Window Functions

group_start_row:

`match(${orders.id}, ${orders.id})`

next_group_start_row:

`count(${orders.id}) - match(${orders.id}, offset(${orders.id}, count(${orders.id}) - row()*2 + 1)) + 2`
 

Once you have starting and ending row, you can make all kinds of functions:
Grouped count:

`${next_group_start_row} - ${group_start_row}`

Grouped sum:

`sum(offset_list(${products.retail_price}, -1 * (row() - ${group_start_row}), ${next_group_start_row} - ${group_start_row}))`

Grouped running total:

`sum(offset_list(${products.retail_price}, -1 * (row() - ${group_start_row}), row() - ${group_start_row} + 1))`

Max date in Group (the date must be sorted desc):

`index(${products.date}, ${group_start_row})`

### Custom Measure Filter current Q

`ceiling(extract_months(trunc_months(${conversion2_f.show_first_quarter}))/3) = ceiling(extract_months(trunc_months(now()))/3) AND (extract_years(${conversion2_f.show_first_quarter}) = extract_years(now()))`