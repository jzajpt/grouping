# Grouping

Grouping exercise - identify rows in a CSV file that __may__ represent the
__same person__ based on a provided __Matching Type__ strategy.

## Installation

Clone the repo, make sure you have required ruby version (see `.ruby-version`)
and install dependencies via bundler:

    $ bundle install

## Usage

The program can be run using `bin/grouping`:

    $ bin/grouping -i [input file] -m [matching type]

Where matching type can be one of following:

* same_email - matches records with the same email address
* same_phone - matches records with the same phone number
* same_email_or_phone - matches records with the same email address OR the same phone number

