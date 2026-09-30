## Overview

PurchasePath is an end-to-end product analytics project using Google Analytics 4 e-commerce event data in BigQuery.

The project models millions of raw behavioral events into user- and session-level purchase journeys to understand where conversion breaks down, which customer segments are driving those gaps, and where the business should prioritize improvement efforts.

Rather than treating funnel, acquisition, retention, and product performance as separate analyses, the project is centered on one business decision:

> **Which customer segment should the business prioritize to improve purchase conversion, and how large is the modeled opportunity?**

## Analytical Approach

The analysis will:

- Build a clean session-level model from raw GA4 event data
- Construct a multi-step purchase funnel from product view through purchase
- Identify the largest meaningful conversion drop-offs
- Compare performance across device, acquisition, geography, and product segments
- Test whether observed differences remain meaningful within comparable groups
- Quantify uncertainty using statistical analysis in Python
- Estimate modeled revenue opportunities under realistic conversion-lift scenarios
- Design an A/B test around the strongest validated opportunity
- Present the recommendation through Tableau and a stakeholder-facing summary

## Supporting Analysis

Additional analysis may include:

- Acquisition performance
- Product and category performance
- New vs. returning user behavior
- Retention and repeat purchasing

These analyses will support the central business question rather than operate as separate standalone studies.
