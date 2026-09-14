# PurchasePath — GA4 E-commerce Product & Growth Analytics

PurchasePath is an end-to-end Data Analyst portfolio project focused on understanding how users move through an e-commerce customer journey, from acquisition and product discovery to cart, checkout, purchase, and repeat behavior.

The project uses Google Analytics 4 event-level e-commerce data in BigQuery to identify where users drop off, which channels, products, devices, and customer segments perform differently, and where the largest opportunities exist to improve conversion, retention, and revenue.

## Business Problem

An e-commerce business may generate large amounts of website traffic without clearly understanding which parts of the customer journey are performing well and where potential customers are being lost.

This project aims to answer:

> **Where are users dropping out of the purchase journey, which segments are driving those patterns, and which areas should the business prioritize to improve growth and revenue?**

## Key Analysis Areas

- Acquisition and traffic-source performance
- Customer journey and multi-step funnel analysis
- Cart and checkout abandonment
- Conversion by device, channel, geography, and product
- Product engagement and purchase performance
- Cohort and retention analysis
- New vs. returning user behavior
- Revenue and average order value
- Behavioral segmentation
- Growth opportunity sizing
- Experiment recommendation based on analytical findings

## Data

The project uses Google's public GA4 e-commerce sample dataset hosted in BigQuery.

The raw data is event-level and contains user actions such as:

```text
session_start
page_view
view_item
add_to_cart
begin_checkout
purchase
