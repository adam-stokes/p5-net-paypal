requires "DDP" => "0";
requires "Mojo::Base" => "0";
requires "Mojo::Parameters" => "0";
requires "Mojo::URL" => "0";
requires "Mojo::UserAgent" => "0";

on 'test' => sub {
  requires "Mojolicious" => "0";
  requires "Pod::Elemental::Transformer::List" => "0";
  requires "Pod::Weaver::Section::WarrantyDisclaimer" => "0";
  requires "Test::Mojo" => "0";
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
};
